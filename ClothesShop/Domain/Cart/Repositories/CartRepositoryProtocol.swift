protocol CartRepositoryProtocol {
    func fetchCart(ownerID: String, completion: @escaping (Result<[CartItem], Error>) -> Void)
    func saveCartItem(ownerID: String, item: CartItem,
                      completion: @escaping (Result<Void, Error>) -> Void)
    func deleteCartItem(ownerID: String, itemID: String,
                        completion: @escaping (Result<Void, Error>) -> Void)
    func clearCart(ownerID: String, itemIDs: [String],
                   completion: @escaping (Result<Void, Error>) -> Void)
}
