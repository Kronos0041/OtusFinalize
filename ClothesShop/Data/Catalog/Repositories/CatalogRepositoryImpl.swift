final class CatalogRepositoryImpl: CatalogRepositoryProtocol {
    private let remoteDataSource: CatalogRemoteDataSourceProtocol

    init(remoteDataSource: CatalogRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCatalog(completion: @escaping (Result<Catalog, Error>) -> Void) {
        remoteDataSource.fetchCatalog { completion($0.map(CatalogMapper.map)) }
    }
}
