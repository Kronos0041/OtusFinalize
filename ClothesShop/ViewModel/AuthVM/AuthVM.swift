//
//  AuthVM.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation

/// Сообщение об ошибке над полями ввода.
struct AuthBanner: Equatable {
    var message: String
    var isVisible: Bool

    static let hidden = AuthBanner(message: "", isVisible: false)

    static func error(_ message: String) -> AuthBanner {
        AuthBanner(message: message, isVisible: true)
    }
}

final class AuthVM: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var repeatPassword = ""

    @Published var banner = AuthBanner.hidden
    @Published private(set) var isSubmitting = false
    /// Начальное значение берётся синхронно, чтобы сохранённая сессия сразу открыла нужный экран.
    @Published private(set) var sessionState = AuthenticationService.sessionState
    @Published private(set) var verificationMessage = ""

    var isSignedIn: Bool { sessionState == .verified }
    var pendingEmail: String? {
        guard case .awaitingEmailVerification(let email) = sessionState else { return nil }
        return email
    }

    // Навигация
    @Published var nextAuth = false

    private var authObservation: AuthStateObservation?

    /// Минимум Firebase Authentication для входа по email и паролю.
    private static let minPasswordLength = 6

    private static let emailPredicate = NSPredicate(
        format: "SELF MATCHES %@",
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    )
}

// MARK: - Actions

extension AuthVM {
    /// Открыть экран входа/регистрации с чистым баннером.
    func openAuthScreen() {
        banner = .hidden
        nextAuth = true
    }

    func submit(mode: AuthState) {
        guard !isSubmitting else { return }
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if let message = validationError(for: mode) {
            banner = .error(message)
            return
        }

        banner = .hidden
        isSubmitting = true

        switch mode {
        case .auth:
            AuthenticationService.signIn(email: email, password: password) { [weak self] result in
                self?.handleAuthResult(result, mode: mode)
            }
        case .reg:
            AuthenticationService.register(email: email, password: password) { [weak self] result in
                self?.handleAuthResult(result, mode: mode)
            }
        }
    }

    /// Подписывается на состояние авторизации один раз за жизнь VM.
    func checkHaveUser() {
        guard authObservation == nil else { return }
        authObservation = AuthenticationService.observeAuthState { [weak self] state in
            self?.setSessionState(state)
        }
    }

    func resendVerificationEmail() {
        guard !isSubmitting else { return }
        isSubmitting = true
        verificationMessage = ""
        AuthenticationService.sendEmailVerification { [weak self] result in
            self?.isSubmitting = false
            switch result {
            case .success:
                self?.verificationMessage = SwiftGen.Auth.Verification.resent
            case .failure(let error):
                self?.verificationMessage = AuthenticationService.accountErrorMessage(error, verifyingCurrentPassword: false)
            }
        }
    }

    func checkEmailVerification() {
        guard !isSubmitting else { return }
        isSubmitting = true
        verificationMessage = ""
        AuthenticationService.refreshEmailVerification { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success(true):
                self.setSessionState(.verified)
            case .success(false):
                self.verificationMessage = SwiftGen.Auth.Verification.notConfirmed
            case .failure(let error):
                self.verificationMessage = AuthenticationService.accountErrorMessage(error, verifyingCurrentPassword: false)
            }
        }
    }

    func leaveVerificationScreen() {
        do {
            try AuthenticationService.signOut()
            setSessionState(.signedOut)
        } catch {
            verificationMessage = AuthenticationService.accountErrorMessage(error, verifyingCurrentPassword: false)
        }
    }

    private func handleAuthResult(_ result: Result<Void, Error>, mode: AuthState) {
        isSubmitting = false
        switch result {
        case .success:
            setSessionState(AuthenticationService.sessionState)
            if pendingEmail != nil {
                verificationMessage = mode == .reg
                    ? SwiftGen.Auth.Verification.sent
                    : SwiftGen.Auth.Verification.required
            }
        case .failure(let error):
            if pendingEmail != nil {
                verificationMessage = SwiftGen.Auth.Verification.sendFailed(AuthenticationService.accountErrorMessage(error, verifyingCurrentPassword: false))
            } else {
                banner = .error(AuthenticationService.accountErrorMessage(error, verifyingCurrentPassword: false))
            }
        }
    }

    private func setSessionState(_ state: AuthSessionState) {
        sessionState = state
        switch state {
        case .signedOut:
            verificationMessage = ""
            nextAuth = false
        case .awaitingEmailVerification, .verified:
            // Экран авторизации больше не нужен: иначе после выхода он откроется сам.
            nextAuth = false
            password = ""
            repeatPassword = ""
            banner = .hidden
        }
    }
}

// MARK: - Validation

extension AuthVM {
    /// Вызывается из `TextField(onEditingChanged:)`. Проверяет почту, когда поле теряет фокус.
    func emailEditingChanged(isEditing: Bool) {
        guard !email.isEmpty else {
            banner.isVisible = false
            return
        }
        guard !isEditing else { return }

        banner = isValidEmail(email) ? .hidden : .error(SwiftGen.Auth.Error.invalidEmail)
    }

    func isValidEmail(_ email: String) -> Bool {
        Self.emailPredicate.evaluate(with: email)
    }

    /// Текст первой найденной ошибки формы или `nil`, если всё корректно.
    /// Порядок проверок совпадает с прежним.
    private func validationError(for mode: AuthState) -> String? {
        guard isValidEmail(email) else { return SwiftGen.Auth.Error.invalidEmail }
        guard !password.isEmpty else { return SwiftGen.Auth.Error.passwordRequired }
        guard mode == .reg else { return nil }
        guard password.count >= Self.minPasswordLength else {
            return SwiftGen.Auth.Error.passwordTooShort(Self.minPasswordLength)
        }
        guard password == repeatPassword else { return SwiftGen.Auth.Error.passwordMismatch }
        return nil
    }
}
