struct GetStoreSettingsUseCase {
    private let repository: StoreSettingsRepositoryProtocol

    init(repository: StoreSettingsRepositoryProtocol) { self.repository = repository }

    func execute(completion: @escaping (Result<StoreSettings, Error>) -> Void) {
        repository.fetchSettings(completion: completion)
    }
}
