#if DEBUG
import Foundation

/// Mock-контейнер для SwiftUI Preview.
///
/// Фабрики ViewModel те же, что в приложении, но репозитории — mock в памяти, без Firebase и сети.
/// Состояние экрана (контент, пусто, нет сети, ошибка, загрузка) задаётся ответами репозиториев,
/// поэтому в ViewModel нет кода для превью.
///
///     let container = AppDIContainer.mock(catalog: .failure(MockError("Сервер недоступен")))
///     CatalogView(...)
///         .environment(container.makeLoadedCatalogViewModel())
extension AppDIContainer {
    static func mock(
        authSession: AuthSession = .verified,
        isConnected: Bool = true,
        catalog: MockResponse<Catalog> = .success(PreviewData.catalog),
        favoriteIDs: Set<String> = [],
        cartItems: [CartItem] = PreviewData.cartRecords,
        settings: MockResponse<StoreSettings> = .success(.default),
        notifications: MockResponse<[Notification]> = .success(PreviewData.notifications),
        readNotificationIDs: Set<String> = [],
        profile: MockResponse<UserProfile> = .success(PreviewData.profile)
    ) -> AppDIContainer {
        AppDIContainer(repositories: AppRepositories(
            auth: MockAuthRepository(session: authSession),
            profile: MockProfileRepository(response: profile),
            catalog: MockCatalogRepository(response: catalog),
            cart: MockCartRepository(items: cartItems),
            settings: MockStoreSettingsRepository(response: settings),
            favorites: MockFavoritesRepository(ids: favoriteIDs),
            notifications: MockNotificationsRepository(
                response: notifications,
                readIDs: readNotificationIDs
            ),
            connectivity: MockConnectivityRepository(isConnected: isConnected),
            imageCache: MockImageCacheRepository()
        ))
    }

    // MARK: - ViewModel с запущенной загрузкой

    // Экраны, которые грузят данные сами в `onAppear`, этих фабрик не требуют.
    // Они нужны превью отдельных компонентов, где загрузку никто не запускает.

    func makeLoadedCatalogViewModel() -> CatalogViewModel {
        let viewModel = makeCatalogViewModel(automaticallyReloads: false)
        viewModel.reload()
        return viewModel
    }

    /// Корзина берёт названия и цены из каталога, поэтому сначала получает товары.
    func makeLoadedCartViewModel(
        products: [CatalogItemUIModel] = PreviewData.catalogItems
    ) -> CartViewModel {
        let viewModel = makeCartViewModel()
        viewModel.updateCatalog(products)
        viewModel.reload()
        return viewModel
    }

    func makeLoadedNotificationsViewModel() -> NotificationsViewModel {
        let viewModel = makeNotificationsViewModel()
        viewModel.reload()
        return viewModel
    }

    func makeLoadedProfileViewModel() -> ProfileViewModel {
        let viewModel = makeProfileViewModel()
        viewModel.loadProfile()
        return viewModel
    }
}
#endif
