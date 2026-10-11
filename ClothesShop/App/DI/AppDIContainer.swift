import FirebaseFirestore

/// Composition root: единственное место, где Domain-протоколы связываются с реализациями
/// из Data и Infrastructure. Работает в главном потоке, как и создаваемые им ViewModel.
@MainActor
final class AppDIContainer {
    static let shared = AppDIContainer.live()

    /// Реализации Domain-репозиториев, из которых контейнер собирает use case и ViewModel.
    struct Repositories {
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

    private let authRepository: AuthRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let catalogRepository: CatalogRepositoryProtocol
    private let cartRepository: CartRepositoryProtocol
    private let settingsRepository: StoreSettingsRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let notificationsRepository: NotificationsRepositoryProtocol
    private let connectivityRepository: ConnectivityRepositoryProtocol
    private let imageCacheRepository: ImageCacheRepositoryProtocol

    init(repositories: Repositories) {
        authRepository = repositories.auth
        profileRepository = repositories.profile
        catalogRepository = repositories.catalog
        cartRepository = repositories.cart
        settingsRepository = repositories.settings
        favoritesRepository = repositories.favorites
        notificationsRepository = repositories.notifications
        connectivityRepository = repositories.connectivity
        imageCacheRepository = repositories.imageCache
    }

    /// Рабочий контейнер: Firebase, UserDefaults, URLCache и монитор сети.
    ///
    /// - Parameter firestore: экземпляр базы; `nil` — стандартный `Firestore.firestore()`.
    ///   Создаётся только после `FirebaseConfigurator.configure()`, поэтому не задан значением по умолчанию.
    static func live(
        firestore: Firestore? = nil,
        authRemoteDataSource: AuthRemoteDataSourceProtocol = FirebaseAuthDataSourceImpl(),
        connectivityRepository: ConnectivityRepositoryProtocol = NetworkMonitor()
    ) -> AppDIContainer {
        FirebaseConfigurator.configure()
        // Кэш ставится до первых экранов со значениями по умолчанию:
        // `settings/store` доступен только после входа и применяется после загрузки магазина.
        let imageCacheRepository = URLCacheImageCacheRepositoryImpl(
            memoryCapacityMB: StoreSettings.default.imageMemoryCacheCapacityMB,
            diskCapacityMB: StoreSettings.default.imageDiskCacheCapacityMB
        )
        let database = firestore ?? Firestore.firestore()

        return AppDIContainer(repositories: Repositories(
            auth: AuthRepositoryImpl(remoteDataSource: authRemoteDataSource),
            profile: ProfileRepositoryImpl(remoteDataSource: authRemoteDataSource),
            catalog: CatalogRepositoryImpl(
                remoteDataSource: FirestoreCatalogDataSourceImpl(database: database)
            ),
            cart: CartRepositoryImpl(
                remoteDataSource: FirestoreCartDataSourceImpl(database: database)
            ),
            settings: StoreSettingsRepositoryImpl(
                remoteDataSource: FirestoreSettingsDataSourceImpl(database: database)
            ),
            favorites: FavoritesRepositoryImpl(
                localDataSource: UserDefaultsFavoritesDataSourceImpl()
            ),
            notifications: NotificationsRepositoryImpl(
                remoteDataSource: FirestoreNotificationsDataSourceImpl(database: database),
                readStateDataSource: UserDefaultsNotificationReadStateDataSourceImpl()
            ),
            connectivity: connectivityRepository,
            imageCache: imageCacheRepository
        ))
    }

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            authUseCases: AuthUseCases(repository: authRepository)
        )
    }

    func makeCatalogViewModel(
        ownerID: String? = nil,
        automaticallyReloads: Bool = true
    ) -> CatalogViewModel {
        CatalogViewModel(
            getCatalogUseCase: GetCatalogUseCase(repository: catalogRepository),
            searchProductsUseCase: SearchProductsUseCase(),
            getFavoritesUseCase: GetFavoritesUseCase(repository: favoritesRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository),
            connectivityUseCase: ObserveConnectivityUseCase(repository: connectivityRepository),
            ownerID: ownerID ?? authRepository.currentUserID,
            automaticallyReloads: automaticallyReloads
        )
    }

    func makeCartViewModel(ownerID: String? = nil) -> CartViewModel {
        CartViewModel(
            ownerID: ownerID ?? authRepository.currentUserID,
            cartUseCases: CartUseCases(repository: cartRepository),
            getSettingsUseCase: GetStoreSettingsUseCase(repository: settingsRepository)
        )
    }

    func makeNotificationsViewModel() -> NotificationsViewModel {
        NotificationsViewModel(
            notificationsUseCases: NotificationsUseCases(repository: notificationsRepository),
            connectivityUseCase: ObserveConnectivityUseCase(repository: connectivityRepository)
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            profileUseCases: ProfileUseCases(repository: profileRepository),
            signOutUseCase: SignOutUseCase(repository: authRepository),
            connectivityUseCase: ObserveConnectivityUseCase(repository: connectivityRepository)
        )
    }

    func makeMainTabViewModel() -> MainTabViewModel {
        let catalog = makeCatalogViewModel(automaticallyReloads: false)
        let cart = makeCartViewModel()
        return MainTabViewModel(
            catalog: catalog,
            cart: cart,
            loadStorefrontUseCase: LoadStorefrontUseCase(
                getCatalogUseCase: GetCatalogUseCase(repository: catalogRepository),
                getCartUseCase: GetCartUseCase(repository: cartRepository),
                getStoreSettingsUseCase: GetStoreSettingsUseCase(repository: settingsRepository)
            ),
            getCurrentUserIDUseCase: GetCurrentUserIDUseCase(repository: authRepository),
            configureImageCacheUseCase: ConfigureImageCacheUseCase(repository: imageCacheRepository),
            connectivityUseCase: ObserveConnectivityUseCase(repository: connectivityRepository)
        )
    }
}
