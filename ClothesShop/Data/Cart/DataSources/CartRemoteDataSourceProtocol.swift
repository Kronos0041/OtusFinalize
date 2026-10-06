protocol CartRemoteDataSourceProtocol {
    func fetchCart(ownerID: String, completion: @escaping (Result<[CartRecordDTO], Error>) -> Void)
    func saveCartItem(ownerID: String, item: CartRecordDTO,
                      completion: @escaping (Result<Void, Error>) -> Void)
    func deleteCartItem(ownerID: String, itemID: String,
                        completion: @escaping (Result<Void, Error>) -> Void)
    func clearCart(ownerID: String, itemIDs: [String],
                   completion: @escaping (Result<Void, Error>) -> Void)
}
