#if DEBUG
import Foundation

/// Контейнер для SwiftUI Preview.
///
/// Фабрики ViewModel те же, что в приложении, но репозитории — fake в памяти, без Firebase и сети.
/// Состояние экрана (контент, пусто, нет сети, ошибка, загрузка) задаётся ответами репозиториев,
/// поэтому в ViewModel нет кода для превью.
///
///     let container = AppDIContainer.preview(catalog: .failure(PreviewError("Сервер недоступен")))
///     CatalogView(...)
///         .environment(container.makeLoadedCatalogViewModel())
extension AppDIContainer {
    static func preview(
        authSession: AuthSession = .verified,
        isConnected: Bool = true,
        catalog: PreviewResponse<Catalog> = .success(PreviewData.catalog),
        favoriteIDs: Set<String> = [],
        cartItems: [CartItem] = PreviewData.cartRecords,
        settings: PreviewResponse<StoreSettings> = .success(.default),
        notifications: PreviewResponse<[Notification]> = .success(PreviewData.notifications),
        readNotificationIDs: Set<String> = [],
        profile: PreviewResponse<UserProfile> = .success(PreviewData.profile)
    ) -> AppDIContainer {
        AppDIContainer(repositories: Repositories(
            auth: PreviewAuthRepository(session: authSession),
            profile: PreviewProfileRepository(response: profile),
            catalog: PreviewCatalogRepository(response: catalog),
            cart: PreviewCartRepository(items: cartItems),
            settings: PreviewStoreSettingsRepository(response: settings),
            favorites: PreviewFavoritesRepository(ids: favoriteIDs),
            notifications: PreviewNotificationsRepository(
                response: notifications,
                readIDs: readNotificationIDs
            ),
            connectivity: PreviewConnectivityRepository(isConnected: isConnected),
            imageCache: PreviewImageCacheRepository()
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
