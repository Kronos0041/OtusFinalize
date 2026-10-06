struct GetProfileUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) { self.repository = repository }

    var currentProfile: UserProfile { repository.currentProfile }

    func execute(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        repository.refreshProfile(completion: completion)
    }
}
