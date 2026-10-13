struct GetCatalogUseCase {
    private let repository: CatalogRepositoryProtocol

    init(repository: CatalogRepositoryProtocol) {
        self.repository = repository
    }

    func getCatalog() async throws -> Catalog {
        try await repository.fetchCatalog()
    }
}
