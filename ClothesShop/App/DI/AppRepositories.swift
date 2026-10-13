/// Реализации Domain-репозиториев, из которых `AppDIContainer` собирает use case и ViewModel.
struct AppRepositories {
    let auth: AuthRepositoryProtocol
    let profile: ProfileRepositoryProtocol
    let catalog: CatalogRepositoryProtocol
    let cart: CartRepositoryProtocol
    let settings: StoreSettingsRepositoryProtocol
    let favorites: FavoritesRepositoryProtocol
    let notifications: NotificationsRepositoryProtocol
    let connectivity: ConnectivityRepositoryProtocol
    let imageCache: ImageCacheRepositoryProtocol
}
