import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var repeatPassword = ""
    var banner = AuthBanner.hidden
    private(set) var isSubmitting = false
    private(set) var session: AuthSession
    private(set) var verificationMessage = ""
    /// Стек экранов авторизации. Сбрасывается при смене сессии.
    var path: [AuthRoute] = []

    var isSignedIn: Bool { session == .verified }

    var pendingEmail: String? {
        guard case .awaitingEmailVerification(let email) = session else { return nil }
        return email
    }

    private let signInUseCase: SignInUseCase
    private let registerUseCase: RegisterUseCase
    private let observeSessionUseCase: ObserveAuthSessionUseCase
    private let resendVerificationUseCase: ResendVerificationEmailUseCase
    private let verifyEmailUseCase: VerifyEmailUseCase
    private let signOutUseCase: SignOutUseCase
    private let validator: AuthInputValidator
    @ObservationIgnored private var observation: ObservationToken?

    init(signInUseCase: SignInUseCase,
         registerUseCase: RegisterUseCase,
         observeSessionUseCase: ObserveAuthSessionUseCase,
         resendVerificationUseCase: ResendVerificationEmailUseCase,
         verifyEmailUseCase: VerifyEmailUseCase,
         signOutUseCase: SignOutUseCase,
         validator: AuthInputValidator = AuthInputValidator()) {
        self.signInUseCase = signInUseCase
        self.registerUseCase = registerUseCase
        self.observeSessionUseCase = observeSessionUseCase
        self.resendVerificationUseCase = resendVerificationUseCase
        self.verifyEmailUseCase = verifyEmailUseCase
        self.signOutUseCase = signOutUseCase
        self.validator = validator
        session = observeSessionUseCase.currentSession
    }

    func openAuthForm(mode: AuthMode) {
        banner = .hidden
        path = [.form(mode)]
    }

    func submit(mode: AuthMode) {
        guard !isSubmitting else { return }
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let message = validator.validationMessage(email: email, password: password,
                                                     repeatPassword: repeatPassword, mode: mode) {
            banner = .error(message)
            return
        }
        banner = .hidden
        isSubmitting = true
        Task { [weak self] in await self?.performSubmit(mode: mode) }
    }

    func observeSession() {
        guard observation == nil else { return }
        observation = observeSessionUseCase.execute { [weak self] in self?.setSession($0) }
    }

    func resendVerificationEmail() {
        guard !isSubmitting else { return }
        isSubmitting = true
        verificationMessage = ""
        Task { [weak self] in await self?.performResendVerification() }
    }

    func refreshEmailVerification() {
        guard !isSubmitting else { return }
        isSubmitting = true
        verificationMessage = ""
        Task { [weak self] in await self?.performRefreshVerification() }
    }

    func signOut() {
        do {
            try signOutUseCase.execute()
            setSession(.signedOut)
        } catch {
            verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
        }
    }

    func emailEditingChanged(isEditing: Bool) {
        guard !email.isEmpty else {
            banner.isVisible = false
            return
        }
        guard !isEditing else { return }
        banner = validator.isValidEmail(email) ? .hidden : .error(SwiftGen.Auth.Error.invalidEmail)
    }

    // MARK: - Асинхронные сценарии

    private func performSubmit(mode: AuthMode) async {
        defer { isSubmitting = false }
        do {
            switch mode {
            case .signIn:
                try await signInUseCase.execute(email: email, password: password)
            case .registration:
                try await registerUseCase.execute(email: email, password: password)
            }
            setSession(observeSessionUseCase.currentSession)
            if pendingEmail != nil {
                verificationMessage = mode == .registration
                    ? SwiftGen.Auth.Verification.sent
                    : SwiftGen.Auth.Verification.required
            }
        } catch {
            let message = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
            if pendingEmail != nil {
                verificationMessage = SwiftGen.Auth.Verification.sendFailed(message)
            } else {
                banner = .error(message)
            }
        }
    }

    private func performResendVerification() async {
        defer { isSubmitting = false }
        do {
            try await resendVerificationUseCase.execute()
            verificationMessage = SwiftGen.Auth.Verification.resent
        } catch {
            verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
        }
    }

    private func performRefreshVerification() async {
        defer { isSubmitting = false }
        do {
            if try await verifyEmailUseCase.execute() {
                setSession(.verified)
            } else {
                verificationMessage = SwiftGen.Auth.Verification.notConfirmed
            }
        } catch {
            verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
        }
    }

    private func setSession(_ newSession: AuthSession) {
        session = newSession
        switch newSession {
        case .signedOut:
            verificationMessage = ""
            path = []
        case .awaitingEmailVerification, .verified:
            path = []
            password = ""
            repeatPassword = ""
            banner = .hidden
        }
    }
}
