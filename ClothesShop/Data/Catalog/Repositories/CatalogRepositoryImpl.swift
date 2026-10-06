final class CatalogRepositoryImpl: CatalogRepositoryProtocol {
    private let remoteDataSource: CatalogRemoteDataSourceProtocol

    init(remoteDataSource: CatalogRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCatalog() async throws -> Catalog {
        CatalogMapper.map(try await remoteDataSource.fetchCatalog())
    }
}
