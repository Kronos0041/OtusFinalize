protocol CatalogRemoteDataSourceProtocol {
    func fetchCatalog() async throws -> CatalogDTO
}
