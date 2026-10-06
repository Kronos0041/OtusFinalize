struct GetCartUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) { self.repository = repository }

    func execute(ownerID: String, completion: @escaping (Result<[CartItem], Error>) -> Void) {
        repository.fetchCart(ownerID: ownerID, completion: completion)
    }
}
