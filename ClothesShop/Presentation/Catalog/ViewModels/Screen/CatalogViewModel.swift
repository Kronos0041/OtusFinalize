import Foundation
import Observation

@MainActor
@Observable
final class CatalogViewModel {
    private(set) var mode: ViewMode<[CatalogSectionViewModel]> = .loading
    /// Разделы с учётом поиска. Пересчитываются только при смене каталога или запроса.
    private(set) var filteredSections: [CatalogSectionViewModel] = []
    var selectedCategoryIndex = 0
    var searchText = "" {
        didSet { updateFilteredSections() }
    }
    private(set) var favoriteProductIDs: Set<String>

    /// Вызывается при каждом обновлении каталога. Через него корзина получает актуальные названия и цены.
    @ObservationIgnored var onProductsUpdate: (([CatalogItemViewModel]) -> Void)?

    var sections: [CatalogSectionViewModel] { mode.content ?? [] }

    /// Все товары каталога (раздел «Все»).
    var allProducts: [CatalogItemViewModel] { sections.first?.products ?? [] }

    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private var favoriteProducts: [CatalogItemViewModel] {
        allProducts.filter { favoriteProductIDs.contains($0.id) }
    }

    var favoritesMode: ViewMode<[CatalogItemViewModel]> {
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
    #if DEBUG
    @ObservationIgnored private var isPreview = false
    #endif

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

    #if DEBUG
    func applyPreview(products: [CatalogItemViewModel], favoriteIDs: Set<String> = []) {
        isPreview = true
        favoriteProductIDs = favoriteIDs
        mode = .content([CatalogSectionViewModel(id: CatalogSectionViewModel.allCategory.id,
                                                 category: CatalogSectionViewModel.allCategory,
                                                 products: products)])
        updateFilteredSections()
    }
    #endif

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
        #if DEBUG
        if isPreview { return }
        #endif
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
        mode = .make(from: result.map(CatalogSectionViewModel.sections)) {
            $0.allSatisfy { $0.products.isEmpty }
        }
        if selectedCategoryIndex >= sections.count { selectedCategoryIndex = 0 }
        updateFilteredSections()
        if mode.content != nil { onProductsUpdate?(allProducts) }
    }

    func product(id: String) -> CatalogItemViewModel? {
        allProducts.first { $0.id == id }
    }

    func productMode(id: String) -> ViewMode<CatalogItemViewModel> {
        switch mode {
        case .loading: return .loading
        case .content: return product(id: id).map(ViewMode.content) ?? .empty
        case .empty: return .empty
        case .noInternet: return .noInternet
        case .error(let message): return .error(message)
        }
    }

    func isFavorite(_ product: CatalogItemViewModel) -> Bool {
        favoriteProductIDs.contains(product.id)
    }

    func isSelected(_ index: Int) -> Bool {
        selectedCategoryIndex == index
    }

    func toggleFavorite(_ product: CatalogItemViewModel) {
        guard let ownerID else { return }
        favoriteProductIDs = toggleFavoriteUseCase.execute(productID: product.id,
                                                            ownerID: ownerID,
                                                            currentIDs: favoriteProductIDs)
    }

    /// Фильтрует товары внутри разделов, сохраняя сами разделы: индексы вкладок не сдвигаются.
    private func updateFilteredSections() {
        guard isSearching, let catalog else {
            filteredSections = sections
            return
        }
        let matchingIDs = Set(searchProductsUseCase.execute(products: catalog.products, query: searchText).map(\.id))
        filteredSections = sections.map { section in
            var result = section
            result.products = section.products.filter { matchingIDs.contains($0.id) }
            return result
        }
    }

    private func reloadAfterReconnect() {
        switch mode {
        case .noInternet, .error: reload()
        case .loading, .content, .empty: break
        }
    }
}
