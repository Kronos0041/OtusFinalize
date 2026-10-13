/// Операции формы входа и регистрации: `AuthViewModel` зависит от одного объекта, а не от каждого use case.
/// Сессией и подтверждением почты занимаются `SessionViewModel` и `EmailVerificationViewModel`.
struct AuthUseCases {
    let checkEmail: CheckEmailRegisteredUseCase
    let signIn: SignInUseCase
    let register: RegisterUseCase
    let resetPassword: SendPasswordResetUseCase

    init(repository: AuthRepositoryProtocol) {
        checkEmail = CheckEmailRegisteredUseCase(repository: repository)
        signIn = SignInUseCase(repository: repository)
        register = RegisterUseCase(repository: repository)
        resetPassword = SendPasswordResetUseCase(repository: repository)
    }
}
