/// Проверяет, есть ли аккаунт с этим email: от ответа зависит, просить пароль или придумать новый.
struct CheckEmailRegisteredUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func isEmailRegistered(_ email: String) async throws -> Bool {
        try await repository.isEmailRegistered(email)
    }
}
