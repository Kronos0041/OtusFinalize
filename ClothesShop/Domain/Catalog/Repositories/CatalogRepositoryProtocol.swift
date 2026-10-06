protocol CatalogRepositoryProtocol {
    func fetchCatalog(completion: @escaping (Result<Catalog, Error>) -> Void)
}
