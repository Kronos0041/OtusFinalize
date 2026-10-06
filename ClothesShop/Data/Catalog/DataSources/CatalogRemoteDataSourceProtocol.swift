protocol CatalogRemoteDataSourceProtocol {
    func fetchCatalog(completion: @escaping (Result<CatalogDTO, Error>) -> Void)
}
