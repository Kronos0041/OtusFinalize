import Foundation

final class UserDefaultsFavoritesDataSourceImpl: FavoritesLocalDataSourceProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func favoriteProductIDs(ownerID: String) -> Set<String> {
        Set(defaults.stringArray(forKey: key(ownerID)) ?? [])
    }

    func saveFavoriteProductIDs(_ ids: Set<String>, ownerID: String) {
        defaults.set(ids.sorted(), forKey: key(ownerID))
    }

    private func key(_ ownerID: String) -> String { "favorites.\(ownerID)" }
}
