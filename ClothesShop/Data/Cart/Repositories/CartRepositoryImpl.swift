final class CartRepositoryImpl: CartRepositoryProtocol {
    private let remoteDataSource: CartRemoteDataSourceProtocol

    init(remoteDataSource: CartRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCart(ownerID: String, completion: @escaping (Result<[CartItem], Error>) -> Void) {
        remoteDataSource.fetchCart(ownerID: ownerID) { completion($0.map { $0.map(CartMapper.map) }) }
    }

    func saveCartItem(ownerID: String, item: CartItem,
                      completion: @escaping (Result<Void, Error>) -> Void) {
        remoteDataSource.saveCartItem(ownerID: ownerID, item: CartMapper.map(item),
                                      completion: completion)
    }

    func deleteCartItem(ownerID: String, itemID: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        remoteDataSource.deleteCartItem(ownerID: ownerID, itemID: itemID, completion: completion)
    }

    func clearCart(ownerID: String, itemIDs: [String],
                   completion: @escaping (Result<Void, Error>) -> Void) {
        remoteDataSource.clearCart(ownerID: ownerID, itemIDs: itemIDs, completion: completion)
    }
}
