import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    private(set) var email = ""
    private(set) var password = ""
    private(set) var repeatPassword = ""
    private(set) var banner = AuthBanner.hidden
    private(set) var isSubmitting = false
    private(set) var session: AuthSession
    private(set) var verificationMessage = ""
    /// Стек экранов авторизации. Сбрасывается при смене сессии.
    private(set) var path: [AuthRoute] = []

    var isSignedIn: Bool { session == .verified }

    var pendingEmail: String? {
        guard case .awaitingEmailVerification(let email) = session else { return nil }
        return email
    }

    private let authUseCases: AuthUseCases
    private let validator: AuthInputValidator
    @ObservationIgnored private var observation: ObservationToken?

    init(
        authUseCases: AuthUseCases,
        validator: AuthInputValidator = AuthInputValidator()
    ) {
        self.authUseCases = authUseCases
        self.validator = validator
        session = authUseCases.observeSession.currentSession
    }

    // MARK: - Ввод

    func updateEmail(_ email: String) {
        self.email = email
    }

    func updatePassword(_ password: String) {
        self.password = password
    }

    func updateRepeatPassword(_ repeatPassword: String) {
        self.repeatPassword = repeatPassword
    }

    func dismissBanner() {
        banner = banner.dismissed
    }

    /// Стек экранов меняет `NavigationStack` (кнопка «Назад», свайп).
    func updatePath(_ path: [AuthRoute]) {
        self.path = path
    }

    // MARK: - Сценарии

    func openAuthForm(mode: AuthMode) {
        banner = .hidden
        path = [.form(mode)]
    }

    func submit(mode: AuthMode) {
        guard !isSubmitting else { return }
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let message = validator.validationMessage(
            email: email,
            password: password,
            repeatPassword: repeatPassword,
            mode: mode
        ) {
            banner = .error(message)
            return
        }
        banner = .hidden
        isSubmitting = true
        Task { [weak self] in await self?.performSubmit(mode: mode) }
    }

    func observeSession() {
        guard observation == nil else { return }
        observation = authUseCases.observeSession.observeSession { [weak self] in self?.setSession($0) }
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
            try authUseCases.signOut.signOut()
            setSession(.signedOut)
        } catch {
            verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
        }
    }

    func emailEditingChanged(isEditing: Bool) {
        guard !email.isEmpty else {
            dismissBanner()
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
                try await authUseCases.signIn.signIn(email: email, password: password)
            case .registration:
                try await authUseCases.register.register(email: email, password: password)
            }
            setSession(authUseCases.observeSession.currentSession)
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
            try await authUseCases.resendVerification.resendVerificationEmail()
            verificationMessage = SwiftGen.Auth.Verification.resent
        } catch {
            verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
        }
    }

    private func performRefreshVerification() async {
        defer { isSubmitting = false }
        do {
            if try await authUseCases.verifyEmail.verifyEmail() {
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
