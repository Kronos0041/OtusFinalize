import Foundation
import Observation

/// Форма входа и регистрации по шагам: email → пароль или новый пароль.
/// Создаётся заново при каждом показе входа и уничтожается вместе с ним: введённые данные не переживают
/// вход и выход. Саму сессию после входа или регистрации обновляет подписка в `SessionViewModel`.
@MainActor
@Observable
final class AuthViewModel {
    private(set) var email = ""
    private(set) var password = ""
    private(set) var repeatPassword = ""
    private(set) var isSubmitting = false
    /// Короткое уведомление: ошибка или результат действия.
    private(set) var toast: ToastMessage?
    /// Стек экранов после ввода email.
    private(set) var path: [AuthRoute] = []

    var canContinueWithEmail: Bool { !trimmedEmail.isEmpty && !isSubmitting }
    var canSignIn: Bool { !password.isEmpty && !isSubmitting }
    var canRegister: Bool { !password.isEmpty && !repeatPassword.isEmpty && !isSubmitting }

    private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

    private let authUseCases: AuthUseCases
    private let validator: AuthInputValidator

    init(
        authUseCases: AuthUseCases,
        validator: AuthInputValidator = AuthInputValidator()
    ) {
        self.authUseCases = authUseCases
        self.validator = validator
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

    func dismissToast() {
        toast = nil
    }

    /// Стек экранов меняет `NavigationStack` (кнопка «Назад», свайп).
    func updatePath(_ path: [AuthRoute]) {
        self.path = path
    }

    // MARK: - Сценарии

    /// Шаг 1: проверяем email и открываем ввод пароля или создание нового.
    func continueWithEmail() {
        guard canContinueWithEmail else { return }
        email = trimmedEmail
        guard validator.isValidEmail(email) else {
            toast = .error(SwiftGen.Auth.Error.invalidEmail)
            return
        }
        run { viewModel in
            let isRegistered = try await viewModel.authUseCases.checkEmail.isEmailRegistered(viewModel.email)
            viewModel.password = ""
            viewModel.repeatPassword = ""
            viewModel.path = [isRegistered ? .password : .createPassword]
        }
    }

    func signIn() {
        guard canSignIn else { return }
        run { viewModel in
            try await viewModel.authUseCases.signIn.signIn(email: viewModel.email, password: viewModel.password)
        }
    }

    func register() {
        guard canRegister else { return }
        if let message = validator.newPasswordMessage(password: password, repeatPassword: repeatPassword) {
            toast = .error(message)
            return
        }
        run { viewModel in
            do {
                try await viewModel.authUseCases.register.register(email: viewModel.email, password: viewModel.password)
            } catch AuthRepositoryError.emailAlreadyInUse {
                // Проверка email могла не узнать аккаунт (защита от перебора в Firebase): переходим ко входу.
                viewModel.password = ""
                viewModel.repeatPassword = ""
                viewModel.path = [.password]
                viewModel.toast = .info(SwiftGen.Auth.accountExists)
            }
        }
    }

    func resetPassword() {
        run { viewModel in
            try await viewModel.authUseCases.resetPassword.sendPasswordReset(email: viewModel.email)
            viewModel.toast = .success(SwiftGen.Auth.Password.resetSent(viewModel.email))
        }
    }

    func signIn(with provider: SocialSignInProvider) {
        toast = .info(SwiftGen.Auth.Social.inDevelopment(provider.name))
    }

    // MARK: - Вспомогательное

    /// Запускает запрос: блокирует повторные нажатия, ошибку показывает уведомлением.
    private func run(_ operation: @escaping (AuthViewModel) async throws -> Void) {
        guard !isSubmitting else { return }
        isSubmitting = true
        toast = nil
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }
            do {
                try await operation(self)
            } catch {
                self.toast = .error(AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false))
            }
        }
    }
}
