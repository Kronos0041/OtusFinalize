protocol CatalogRepositoryProtocol {
    func fetchCatalog() async throws -> Catalog
}
