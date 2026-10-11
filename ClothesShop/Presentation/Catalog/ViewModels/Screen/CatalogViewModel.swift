import Foundation
import Observation

@MainActor
@Observable
final class CatalogViewModel {
    private(set) var mode: ViewMode<[CatalogSectionUIModel]> = .loading
    /// Разделы с учётом поиска. Пересчитываются только при смене каталога или запроса.
    private(set) var filteredSections: [CatalogSectionUIModel] = []
    private(set) var selectedCategoryIndex = 0
    private(set) var searchText = ""
    private(set) var favoriteProductIDs: Set<String>

    /// Вызывается при каждом обновлении каталога. Через него корзина получает актуальные названия и цены.
    @ObservationIgnored private var onProductsUpdate: (([CatalogItemUIModel]) -> Void)?

    var sections: [CatalogSectionUIModel] { mode.content ?? [] }

    /// Все товары каталога (раздел «Все»).
    var allProducts: [CatalogItemUIModel] { sections.first?.products ?? [] }

    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private var favoriteProducts: [CatalogItemUIModel] {
        allProducts.filter { favoriteProductIDs.contains($0.id) }
    }

    var favoritesMode: ViewMode<[CatalogItemUIModel]> {
        switch mode {
        case .loading: return .loading
        case .content: return favoriteProducts.isEmpty ? .empty : .content(favoriteProducts)
        case .empty: return .empty
        case .noInternet: return .noInternet
        case .error(let message): return .error(message)
        }
    }

    private let getCatalogUseCase: GetCatalogUseCase
    private let searchProductsUseCase: SearchProductsUseCase
    private let getFavoritesUseCase: GetFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    private let ownerID: String?
    @ObservationIgnored private var catalog: Catalog?
    @ObservationIgnored private var requestInFlight = false
    @ObservationIgnored private var connectivityTask: Task<Void, Never>?

    init(getCatalogUseCase: GetCatalogUseCase,
         searchProductsUseCase: SearchProductsUseCase,
         getFavoritesUseCase: GetFavoritesUseCase,
         toggleFavoriteUseCase: ToggleFavoriteUseCase,
         connectivityUseCase: ObserveConnectivityUseCase,
         ownerID: String?,
         automaticallyReloads: Bool = true) {
        self.getCatalogUseCase = getCatalogUseCase
        self.searchProductsUseCase = searchProductsUseCase
        self.getFavoritesUseCase = getFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.connectivityUseCase = connectivityUseCase
        self.ownerID = ownerID
        favoriteProductIDs = ownerID.map(getFavoritesUseCase.execute) ?? []
        if automaticallyReloads {
            connectivityTask = Task { [weak self, updates = connectivityUseCase.execute()] in
                for await connected in updates where connected {
                    self?.reloadAfterReconnect()
                }
            }
        }
    }

    deinit {
        connectivityTask?.cancel()
    }

    /// Подписка на обновления каталога. Через неё корзина получает актуальные названия и цены.
    func observeProductsUpdates(_ handler: @escaping ([CatalogItemUIModel]) -> Void) {
        onProductsUpdate = handler
    }

    func loadIfNeeded() {
        if mode.content == nil { reload() }
    }

    func reload() {
        Task { [weak self] in await self?.load() }
    }

    /// Для pull-to-refresh: завершается вместе с загрузкой.
    func refresh() async {
        await load()
    }

    func load() async {
        guard !requestInFlight else { return }
        guard connectivityUseCase.isConnected else {
            if mode.content == nil { mode = .noInternet }
            return
        }
        if mode.content == nil { mode = .loading }
        requestInFlight = true
        defer { requestInFlight = false }
        do {
            applyCatalog(.success(try await getCatalogUseCase.execute()))
        } catch {
            applyCatalog(.failure(error))
        }
    }

    func applyCatalog(_ result: Result<Catalog, Error>) {
        // Ошибка повторной загрузки не стирает уже показанный каталог.
        if case .failure = result, mode.content != nil { return }
        if case .success(let catalog) = result { self.catalog = catalog }
        mode = .make(from: result.map(CatalogSectionUIModel.sections)) {
            $0.allSatisfy { $0.products.isEmpty }
        }
        if selectedCategoryIndex >= sections.count { selectedCategoryIndex = 0 }
        updateFilteredSections()
        if mode.content != nil { onProductsUpdate?(allProducts) }
    }

    func product(id: String) -> CatalogItemUIModel? {
        allProducts.first { $0.id == id }
    }

    func productMode(id: String) -> ViewMode<CatalogItemUIModel> {
        switch mode {
        case .loading: return .loading
        case .content: return product(id: id).map(ViewMode.content) ?? .empty
        case .empty: return .empty
        case .noInternet: return .noInternet
        case .error(let message): return .error(message)
        }
    }

    func isFavorite(_ product: CatalogItemUIModel) -> Bool {
        favoriteProductIDs.contains(product.id)
    }

    /// Выбор вкладки категории. Индекс вне диапазона сбрасывается на «Все» при следующем обновлении каталога.
    func selectCategory(at index: Int) {
        guard index >= 0, index != selectedCategoryIndex else { return }
        selectedCategoryIndex = index
    }

    func updateSearchText(_ text: String) {
        guard text != searchText else { return }
        searchText = text
        updateFilteredSections()
    }

    func isSelected(_ index: Int) -> Bool {
        selectedCategoryIndex == index
    }

    func toggleFavorite(_ product: CatalogItemUIModel) {
        guard let ownerID else { return }
        favoriteProductIDs = toggleFavoriteUseCase.execute(
            productID: product.id,
            ownerID: ownerID,
            currentIDs: favoriteProductIDs
        )
    }

    /// Фильтрует товары внутри разделов, сохраняя сами разделы: индексы вкладок не сдвигаются.
    private func updateFilteredSections() {
        guard isSearching, let catalog else {
            filteredSections = sections
            return
        }
        let matchingIDs = Set(searchProductsUseCase.execute(products: catalog.products, query: searchText).map(\.id))
        filteredSections = sections.map { section in
            section.withProducts(section.products.filter { matchingIDs.contains($0.id) })
        }
    }

    private func reloadAfterReconnect() {
        switch mode {
        case .noInternet, .error: reload()
        case .loading, .content, .empty: break
        }
    }
}
