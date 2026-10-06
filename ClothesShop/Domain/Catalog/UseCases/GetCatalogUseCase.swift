struct GetCatalogUseCase {
    private let repository: CatalogRepositoryProtocol

    init(repository: CatalogRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> Catalog {
        try await repository.fetchCatalog()
    }
}
