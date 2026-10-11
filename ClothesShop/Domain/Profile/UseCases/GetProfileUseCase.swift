struct GetProfileUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    /// Профиль из локальной сессии, без запроса к серверу.
    var currentProfile: UserProfile { repository.currentProfile }

    func execute() async throws -> UserProfile {
        try await repository.refreshProfile()
    }
}
