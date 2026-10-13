struct GetCartUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func getCart(ownerID: String) async throws -> [CartItem] {
        try await repository.fetchCart(ownerID: ownerID)
    }
}
