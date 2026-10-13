struct ClearFavoritesUseCase {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) { self.repository = repository }

    func clearFavorites(ownerID: String) -> Set<String> {
        repository.saveFavoriteProductIDs([], ownerID: ownerID)
        return []
    }
}
