struct ToggleFavoriteUseCase {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) { self.repository = repository }

    func toggleFavorite(productID: String, ownerID: String, currentIDs: Set<String>) -> Set<String> {
        var result = currentIDs
        if result.contains(productID) { result.remove(productID) } else { result.insert(productID) }
        repository.saveFavoriteProductIDs(result, ownerID: ownerID)
        return result
    }
}
