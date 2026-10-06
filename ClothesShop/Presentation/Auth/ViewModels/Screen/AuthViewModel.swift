

import Combine
import Foundation

final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var repeatPassword = ""
    @Published var banner = AuthBanner.hidden
    @Published private(set) var isSubmitting = false
    @Published private(set) var session: AuthSession
    @Published private(set) var verificationMessage = ""
    @Published var showsAuthForm = false

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
    private var observation: ObservationToken?

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

    func openAuthForm() {
        banner = .hidden
        showsAuthForm = true
    }

    func submit(mode: AuthMode) {
        guard !isSubmitting else { return }
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let message = validator.validationMessage(email: email, password: password,
                                                     repeatPassword: repeatPassword, mode: mode) {
            banner = .error(message); return
        }
        banner = .hidden
        isSubmitting = true
        let completion: AuthRepositoryProtocol.Completion = { [weak self] in self?.handle($0, mode: mode) }
        switch mode {
        case .signIn: signInUseCase.execute(email: email, password: password, completion: completion)
        case .registration: registerUseCase.execute(email: email, password: password, completion: completion)
        }
    }

    func observeSession() {
        guard observation == nil else { return }
        observation = observeSessionUseCase.execute { [weak self] in self?.setSession($0) }
    }

    func resendVerificationEmail() {
        guard !isSubmitting else { return }
        isSubmitting = true; verificationMessage = ""
        resendVerificationUseCase.execute { [weak self] result in
            self?.isSubmitting = false
            switch result {
            case .success: self?.verificationMessage = SwiftGen.Auth.Verification.resent
            case .failure(let error):
                self?.verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
            }
        }
    }

    func refreshEmailVerification() {
        guard !isSubmitting else { return }
        isSubmitting = true; verificationMessage = ""
        verifyEmailUseCase.execute { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success(true): self.setSession(.verified)
            case .success(false): self.verificationMessage = SwiftGen.Auth.Verification.notConfirmed
            case .failure(let error):
                self.verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
            }
        }
    }

    func signOut() {
        do { try signOutUseCase.execute(); setSession(.signedOut) }
        catch { verificationMessage = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false) }
    }

    func emailEditingChanged(isEditing: Bool) {
        guard !email.isEmpty else { banner.isVisible = false; return }
        guard !isEditing else { return }
        banner = validator.isValidEmail(email) ? .hidden : .error(SwiftGen.Auth.Error.invalidEmail)
    }

    private func handle(_ result: Result<Void, Error>, mode: AuthMode) {
        isSubmitting = false
        switch result {
        case .success:
            setSession(observeSessionUseCase.currentSession)
            if pendingEmail != nil {
                verificationMessage = mode == .registration
                    ? SwiftGen.Auth.Verification.sent : SwiftGen.Auth.Verification.required
            }
        case .failure(let error):
            let message = AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false)
            if pendingEmail != nil { verificationMessage = SwiftGen.Auth.Verification.sendFailed(message) }
            else { banner = .error(message) }
        }
    }

    private func setSession(_ newSession: AuthSession) {
        session = newSession
        switch newSession {
        case .signedOut:
            verificationMessage = ""; showsAuthForm = false
        case .awaitingEmailVerification, .verified:
            showsAuthForm = false; password = ""; repeatPassword = ""; banner = .hidden
        }
    }
}
