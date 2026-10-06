struct GetCatalogUseCase {
    private let repository: CatalogRepositoryProtocol

    init(repository: CatalogRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<Catalog, Error>) -> Void) {
        repository.fetchCatalog(completion: completion)
    }
}
