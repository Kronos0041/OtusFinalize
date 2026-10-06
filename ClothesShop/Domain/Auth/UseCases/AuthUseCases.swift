/// Все операции аутентификации в одном месте: `AuthViewModel` зависит от одного объекта вместо шести.
struct AuthUseCases {
    let signIn: SignInUseCase
    let register: RegisterUseCase
    let observeSession: ObserveAuthSessionUseCase
    let resendVerification: ResendVerificationEmailUseCase
    let verifyEmail: VerifyEmailUseCase
    let signOut: SignOutUseCase

    init(repository: AuthRepositoryProtocol) {
        signIn = SignInUseCase(repository: repository)
        register = RegisterUseCase(repository: repository)
        observeSession = ObserveAuthSessionUseCase(repository: repository)
        resendVerification = ResendVerificationEmailUseCase(repository: repository)
        verifyEmail = VerifyEmailUseCase(repository: repository)
        signOut = SignOutUseCase(repository: repository)
    }
}
