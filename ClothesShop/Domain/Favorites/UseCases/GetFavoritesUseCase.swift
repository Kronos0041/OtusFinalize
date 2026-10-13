struct GetFavoritesUseCase {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) { self.repository = repository }

    func getFavoriteIDs(ownerID: String) -> Set<String> {
        repository.favoriteProductIDs(ownerID: ownerID)
    }
}
