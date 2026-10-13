struct AddCartItemUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func addItem(ownerID: String, item: CartItem) async throws {
        try await repository.saveCartItem(ownerID: ownerID, item: item)
    }
}
