protocol CartRepositoryProtocol {
    func fetchCart(ownerID: String) async throws -> [CartItem]
    func saveCartItem(ownerID: String, item: CartItem) async throws
    func deleteCartItem(ownerID: String, itemID: String) async throws
    func clearCart(ownerID: String, itemIDs: [String]) async throws
}
