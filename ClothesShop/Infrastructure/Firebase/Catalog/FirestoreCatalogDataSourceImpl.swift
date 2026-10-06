import FirebaseFirestore

final class FirestoreCatalogDataSourceImpl: CatalogRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchCatalog(completion: @escaping (Result<CatalogDTO, Error>) -> Void) {
        FirestoreDecoder.fetchAll(.categories, from: database, as: CategoryDTO.self) { [database] categories in
            switch categories {
            case .failure(let error): completion(.failure(error))
            case .success(let categories):
                FirestoreDecoder.fetchAll(.products, from: database, as: ProductDTO.self) { products in
                    completion(products.map { CatalogDTO(categories: categories, products: $0) })
                }
            }
        }
    }
}
