final class CartRepositoryImpl: CartRepositoryProtocol {
    private let remoteDataSource: CartRemoteDataSourceProtocol

    init(remoteDataSource: CartRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCart(ownerID: String) async throws -> [CartItem] {
        let records = try await remoteDataSource.fetchCart(ownerID: ownerID)
        return records.map { CartMapper.map($0) }
    }

    func saveCartItem(ownerID: String, item: CartItem) async throws {
        try await remoteDataSource.saveCartItem(ownerID: ownerID, item: CartMapper.map(item))
    }

    func deleteCartItem(ownerID: String, itemID: String) async throws {
        try await remoteDataSource.deleteCartItem(ownerID: ownerID, itemID: itemID)
    }

    func clearCart(ownerID: String, itemIDs: [String]) async throws {
        try await remoteDataSource.clearCart(ownerID: ownerID, itemIDs: itemIDs)
    }
}
