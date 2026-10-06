protocol FavoritesLocalDataSourceProtocol {
    func favoriteProductIDs(ownerID: String) -> Set<String>
    func saveFavoriteProductIDs(_ ids: Set<String>, ownerID: String)
}
