import FirebaseFirestore

/// Composition root: единственное место, где Domain-протоколы связываются с реализациями
/// из Data и Infrastructure. Работает в главном потоке, как и создаваемые им ViewModel.
@MainActor
final class AppDIContainer {
    static let shared = AppDIContainer()

    private let authRepository: AuthRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let catalogRepository: CatalogRepositoryProtocol
    private let cartRepository: CartRepositoryProtocol
    private let settingsRepository: StoreSettingsRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let notificationsRepository: NotificationsRepositoryProtocol
    private let connectivityRepository: ConnectivityRepositoryProtocol
    private let imageCacheRepository: ImageCacheRepositoryProtocol

    /// - Parameter firestore: экземпляр базы; `nil` — стандартный `Firestore.firestore()`.
    ///   Создаётся только после `FirebaseConfigurator.configure()`, поэтому не задан значением по умолчанию.
    init(
        firestore: Firestore? = nil,
        authRemoteDataSource: AuthRemoteDataSourceProtocol = FirebaseAuthDataSourceImpl(),
        connectivityRepository: ConnectivityRepositoryProtocol = NetworkMonitor()
    ) {
        FirebaseConfigurator.configure()
        // Кэш ставится до первых экранов со значениями по умолчанию:
        // `settings/store` доступен только после входа и применяется после загрузки магазина.
        imageCacheRepository = URLCacheImageCacheRepositoryImpl(
            memoryCapacityMB: StoreSettings.default.imageMemoryCacheCapacityMB,
            diskCapacityMB: StoreSettings.default.imageDiskCacheCapacityMB
        )
        let database = firestore ?? Firestore.firestore()

        let catalogDataSource = FirestoreCatalogDataSourceImpl(database: database)
        let cartDataSource = FirestoreCartDataSourceImpl(database: database)
        let settingsDataSource = FirestoreSettingsDataSourceImpl(database: database)
        let notificationsDataSource = FirestoreNotificationsDataSourceImpl(database: database)

        authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource)
        profileRepository = ProfileRepositoryImpl(remoteDataSource: authRemoteDataSource)
        catalogRepository = CatalogRepositoryImpl(remoteDataSource: catalogDataSource)
        cartRepository = CartRepositoryImpl(remoteDataSource: cartDataSource)
        settingsRepository = StoreSettingsRepositoryImpl(remoteDataSource: settingsDataSource)
        favoritesRepository = FavoritesRepositoryImpl(
            localDataSource: UserDefaultsFavoritesDataSourceImpl()
        )
        notificationsRepository = NotificationsRepositoryImpl(
            remoteDataSource: notificationsDataSource,
            readStateDataSource: UserDefaultsNotificationReadStateDataSourceImpl()
        )
        self.connectivityRepository = connectivityRepository
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
