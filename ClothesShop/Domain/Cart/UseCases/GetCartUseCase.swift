struct GetCartUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func execute(ownerID: String) async throws -> [CartItem] {
        try await repository.fetchCart(ownerID: ownerID)
    }
}
