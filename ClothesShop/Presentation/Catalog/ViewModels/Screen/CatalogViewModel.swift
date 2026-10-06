

import Combine
import Foundation

final class CatalogViewModel: ObservableObject {
    @Published private(set) var mode: ViewMode<[CatalogSectionViewModel]> = .loading
    @Published var selectedCategoryIndex = 0
    @Published var searchText = ""
    @Published private(set) var favoriteProductIDs: Set<String>

    var sections: [CatalogSectionViewModel] { mode.content ?? [] }
    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var filteredSections: [CatalogSectionViewModel] {
        let terms = searchText.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !terms.isEmpty else { return sections }
        return sections.map { section in
            var result = section
            result.products = section.products.filter { item in
                let text = [item.title, item.shortDescription, item.description].joined(separator: " ")
                return terms.allSatisfy { text.localizedStandardContains($0) }
            }
            return result
        }
    }
    var favoriteProducts: [CatalogItemViewModel] {
        (sections.first?.products ?? []).filter { favoriteProductIDs.contains($0.id) }
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
    private let getFavoritesUseCase: GetFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    private let ownerID: String?
    private var requestInFlight = false
    private var connectivityObservation: ObservationToken?
    #if DEBUG
    private var isPreview = false
    #endif

    init(getCatalogUseCase: GetCatalogUseCase,
         getFavoritesUseCase: GetFavoritesUseCase,
         toggleFavoriteUseCase: ToggleFavoriteUseCase,
         connectivityUseCase: ObserveConnectivityUseCase,
         ownerID: String?,
         automaticallyReloads: Bool = true) {
        self.getCatalogUseCase = getCatalogUseCase
        self.getFavoritesUseCase = getFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.connectivityUseCase = connectivityUseCase
        self.ownerID = ownerID
        favoriteProductIDs = ownerID.map(getFavoritesUseCase.execute) ?? []
        if automaticallyReloads {
            connectivityObservation = connectivityUseCase.execute { [weak self] connected in
                if connected { self?.reloadAfterReconnect() }
            }
        }
    }

    #if DEBUG
    func applyPreview(products: [CatalogItemViewModel], favoriteIDs: Set<String> = []) {
        isPreview = true; favoriteProductIDs = favoriteIDs
        mode = .content([CatalogSectionViewModel(id: CatalogSectionViewModel.allCategory.id,
                                                  category: CatalogSectionViewModel.allCategory,
                                                  products: products)])
    }
    #endif

    func loadIfNeeded() { if mode.content == nil { reload() } }

    func reload(completion: (() -> Void)? = nil) {
        #if DEBUG
        if isPreview { completion?(); return }
        #endif
        guard !requestInFlight else { completion?(); return }
        guard connectivityUseCase.isConnected else {
            if mode.content == nil { mode = .noInternet }; completion?(); return
        }
        if mode.content == nil { mode = .loading }
        requestInFlight = true
        getCatalogUseCase.execute { [weak self] result in
            self?.requestInFlight = false
            self?.applyCatalog(result)
            completion?()
        }
    }

    func refresh() async {
        await withCheckedContinuation { continuation in reload { continuation.resume() } }
    }

    func applyCatalog(_ result: Result<Catalog, Error>) {
        if case .failure = result, mode.content != nil { return }
        mode = .make(from: result.map(CatalogSectionViewModel.sections)) {
            $0.allSatisfy { $0.products.isEmpty }
        }
        if selectedCategoryIndex >= sections.count { selectedCategoryIndex = 0 }
    }

    func product(id: String) -> CatalogItemViewModel? {
        sections.first?.products.first { $0.id == id }
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

    func isSelected(_ index: Int) -> Bool { selectedCategoryIndex == index }

    func toggleFavorite(_ product: CatalogItemViewModel) {
        guard let ownerID else { return }
        favoriteProductIDs = toggleFavoriteUseCase.execute(productID: product.id,
                                                            ownerID: ownerID,
                                                            currentIDs: favoriteProductIDs)
    }

    private func reloadAfterReconnect() {
        switch mode {
        case .noInternet, .error: reload()
        case .loading, .content, .empty: break
        }
    }
}
