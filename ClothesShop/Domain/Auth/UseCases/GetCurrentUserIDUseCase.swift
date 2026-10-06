/// Идентификатор вошедшего пользователя или `nil`, если вход не выполнен.
struct GetCurrentUserIDUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> String? {
        repository.currentUserID
    }
}
