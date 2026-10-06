struct RemoveCartItemUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) { self.repository = repository }

    func execute(ownerID: String, itemID: String,
                 completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteCartItem(ownerID: ownerID, itemID: itemID, completion: completion)
    }
}
