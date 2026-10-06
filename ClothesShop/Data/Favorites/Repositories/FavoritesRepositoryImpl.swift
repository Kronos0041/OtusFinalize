final class FavoritesRepositoryImpl: FavoritesRepositoryProtocol {
    private let localDataSource: FavoritesLocalDataSourceProtocol

    init(localDataSource: FavoritesLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    func favoriteProductIDs(ownerID: String) -> Set<String> {
        localDataSource.favoriteProductIDs(ownerID: ownerID)
    }

    func saveFavoriteProductIDs(_ ids: Set<String>, ownerID: String) {
        localDataSource.saveFavoriteProductIDs(ids, ownerID: ownerID)
    }
}
