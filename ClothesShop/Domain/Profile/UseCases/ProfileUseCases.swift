/// Операции над профилем. Выход из аккаунта (`SignOutUseCase`) относится к аутентификации и остаётся отдельно.
struct ProfileUseCases {
    let get: GetProfileUseCase
    let changePassword: ChangePasswordUseCase
    let changeEmail: ChangeEmailUseCase

    init(repository: ProfileRepositoryProtocol) {
        get = GetProfileUseCase(repository: repository)
        changePassword = ChangePasswordUseCase(repository: repository)
        changeEmail = ChangeEmailUseCase(repository: repository)
    }
}
