protocol CartRemoteDataSourceProtocol {
    func fetchCart(ownerID: String) async throws -> [CartRecordDTO]
    func saveCartItem(ownerID: String, item: CartRecordDTO) async throws
    func deleteCartItem(ownerID: String, itemID: String) async throws
    func clearCart(ownerID: String, itemIDs: [String]) async throws
}
