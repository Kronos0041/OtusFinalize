struct RemoveCartItemUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func removeItem(ownerID: String, itemID: String) async throws {
        try await repository.deleteCartItem(ownerID: ownerID, itemID: itemID)
    }
}
