import Foundation
import Observation

/// Владеет общими для вкладок ViewModel каталога и корзины и их стартовой загрузкой.
@MainActor
@Observable
final class MainTabViewModel {
    @ObservationIgnored private var state: MainTabViewState = .idle
    /// Число повторов загрузки картинок из `settings/store`; до загрузки — значение по умолчанию.
    private(set) var imageLoadMaxAttempts = StoreSettings.default.imageLoadMaxAttempts

    let catalog: CatalogViewModel
    let cart: CartViewModel

    private let getShopDataUseCase: GetShopDataUseCase
    private let getCurrentUserIDUseCase: GetCurrentUserIDUseCase
    private let configureImageCacheUseCase: ConfigureImageCacheUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    @ObservationIgnored private var didStartInitialLoad = false
    @ObservationIgnored private var connectivityTask: Task<Void, Never>?

    init(catalog: CatalogViewModel,
         cart: CartViewModel,
         getShopDataUseCase: GetShopDataUseCase,
         getCurrentUserIDUseCase: GetCurrentUserIDUseCase,
         configureImageCacheUseCase: ConfigureImageCacheUseCase,
         connectivityUseCase: ObserveConnectivityUseCase) {
        self.catalog = catalog
        self.cart = cart
        self.getShopDataUseCase = getShopDataUseCase
        self.getCurrentUserIDUseCase = getCurrentUserIDUseCase
        self.configureImageCacheUseCase = configureImageCacheUseCase
        self.connectivityUseCase = connectivityUseCase

        // Корзина берёт названия и цены из каталога: любое обновление каталога
        // (стартовое, pull-to-refresh, после восстановления сети) сразу попадает в неё.
        catalog.observeProductsUpdates { [weak cart] products in cart?.updateCatalog(products) }

        connectivityTask = Task { [weak self, updates = connectivityUseCase.observeConnectivity()] in
            for await connected in updates where connected {
                self?.loadIfNeeded()
            }
        }
    }

    deinit {
        connectivityTask?.cancel()
    }

    func loadIfNeeded() {
        guard !didStartInitialLoad, state != .loading,
              let ownerID = getCurrentUserIDUseCase.getCurrentUserID() else { return }
        guard connectivityUseCase.isConnected else {
            catalog.applyCatalog(.failure(ConnectivityError.offline))
            cart.applySettings(.failure(ConnectivityError.offline))
            return
        }
        didStartInitialLoad = true
        state = .loading
        Task { [weak self] in await self?.loadShopData(ownerID: ownerID) }
    }

    /// Повтор загрузки корзины: если каталога ещё нет, сначала загружается он.
    func reloadCart() {
        Task { [weak self] in
            guard let self else { return }
            if self.catalog.mode.content == nil { await self.catalog.load() }
            await self.cart.load()
        }
    }

    private func loadShopData(ownerID: String) async {
        let result = await getShopDataUseCase.getShopData(ownerID: ownerID)
        state = .loaded
        if case .failure = result.catalog { didStartInitialLoad = false }
        if case .failure = result.cart { didStartInitialLoad = false }
        if case .failure = result.settings { didStartInitialLoad = false }

        if case .success(let settings) = result.settings {
            imageLoadMaxAttempts = settings.imageLoadMaxAttempts
            configureImageCacheUseCase.configureImageCache(settings: settings)
        }

        catalog.applyCatalog(result.catalog)
        switch (result.catalog, result.settings) {
        case (.success, .success):
            guard cart.applySettings(result.settings) else { return }
            cart.apply(result.cart)
        case (.failure(let error), _):
            cart.apply(.failure(error))
        case (_, .failure):
            cart.applySettings(result.settings)
        }
    }
}
