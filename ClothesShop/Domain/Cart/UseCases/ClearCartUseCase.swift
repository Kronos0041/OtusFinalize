struct ClearCartUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) { self.repository = repository }

    func execute(ownerID: String, itemIDs: [String],
                 completion: @escaping (Result<Void, Error>) -> Void) {
        repository.clearCart(ownerID: ownerID, itemIDs: itemIDs, completion: completion)
    }
}
