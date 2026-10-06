import FirebaseFirestore

final class FirestoreCatalogDataSourceImpl: CatalogRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    /// Категории и товары читаются параллельно.
    func fetchCatalog() async throws -> CatalogDTO {
        async let categories = FirestoreDecoder.fetchAll(.categories, from: database, as: CategoryDTO.self)
        async let products = FirestoreDecoder.fetchAll(.products, from: database, as: ProductDTO.self)
        return CatalogDTO(categories: try await categories, products: try await products)
    }
}
