#if DEBUG
import Foundation

final class MockFavoritesRepository: FavoritesRepositoryProtocol {
    private var ids: Set<String>

    init(ids: Set<String>) {
        self.ids = ids
    }

    func favoriteProductIDs(ownerID: String) -> Set<String> { ids }
    func saveFavoriteProductIDs(_ ids: Set<String>, ownerID: String) { self.ids = ids }
}
#endif
