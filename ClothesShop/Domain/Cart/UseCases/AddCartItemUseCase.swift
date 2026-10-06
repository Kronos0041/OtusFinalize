struct AddCartItemUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) { self.repository = repository }

    func execute(ownerID: String, item: CartItem,
                 completion: @escaping (Result<Void, Error>) -> Void) {
        repository.saveCartItem(ownerID: ownerID, item: item, completion: completion)
    }
}
