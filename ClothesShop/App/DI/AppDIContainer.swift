import FirebaseFirestore

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

    /// - Parameter firestore: экземпляр базы; `nil` — стандартный `Firestore.firestore()`.
    ///   Создаётся только после `FirebaseConfigurator.configure()`, поэтому не задан значением по умолчанию.
    init(firestore: Firestore? = nil,
         authRemoteDataSource: AuthRemoteDataSourceProtocol = FirebaseAuthDataSourceImpl(),
         connectivityRepository: ConnectivityRepositoryProtocol = NetworkMonitor.shared) {
        FirebaseConfigurator.configure()
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
            signInUseCase: SignInUseCase(repository: authRepository),
            registerUseCase: RegisterUseCase(repository: authRepository),
            observeSessionUseCase: ObserveAuthSessionUseCase(repository: authRepository),
            resendVerificationUseCase: ResendVerificationEmailUseCase(repository: authRepository),
            verifyEmailUseCase: VerifyEmailUseCase(repository: authRepository),
            signOutUseCase: SignOutUseCase(repository: authRepository)
        )
    }

    func makeCatalogViewModel(ownerID: String? = nil,
                              automaticallyReloads: Bool = true) -> CatalogViewModel {
        CatalogViewModel(
            getCatalogUseCase: GetCatalogUseCase(repository: catalogRepository),
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
            getCartUseCase: GetCartUseCase(repository: cartRepository),
            addCartItemUseCase: AddCartItemUseCase(repository: cartRepository),
            removeCartItemUseCase: RemoveCartItemUseCase(repository: cartRepository),
            clearCartUseCase: ClearCartUseCase(repository: cartRepository),
            getSettingsUseCase: GetStoreSettingsUseCase(repository: settingsRepository)
        )
    }

    func makeNotificationsViewModel() -> NotificationsViewModel {
        NotificationsViewModel(
            getNotificationsUseCase: GetNotificationsUseCase(repository: notificationsRepository),
            getReadIDsUseCase: GetReadNotificationIDsUseCase(repository: notificationsRepository),
            markReadUseCase: MarkNotificationReadUseCase(repository: notificationsRepository),
            connectivityUseCase: ObserveConnectivityUseCase(repository: connectivityRepository)
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            getProfileUseCase: GetProfileUseCase(repository: profileRepository),
            changePasswordUseCase: ChangePasswordUseCase(repository: profileRepository),
            changeEmailUseCase: ChangeEmailUseCase(repository: profileRepository),
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
                catalogRepository: catalogRepository,
                cartRepository: cartRepository,
                settingsRepository: settingsRepository
            ),
            authRepository: authRepository,
            connectivityUseCase: ObserveConnectivityUseCase(repository: connectivityRepository)
        )
    }
}
