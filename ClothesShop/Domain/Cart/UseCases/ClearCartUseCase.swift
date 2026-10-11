struct ClearCartUseCase {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func execute(ownerID: String, itemIDs: [String]) async throws {
        try await repository.clearCart(ownerID: ownerID, itemIDs: itemIDs)
    }
}
