//
//  MainGrideVM.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation
import Combine

/// Состояние каталога: режим экрана, выбранная вкладка и лайки.
///
/// Каталог всегда загружается из Firestore; локальной копии данных в приложении нет.
/// Лайки хранятся одним множеством id, поэтому товар в «Все» и в своей категории синхронен.
final class MainGrideVM: ObservableObject {
    @Published private(set) var viewMode: ViewMode<[ShopItemModel]> = .loading
    @Published var selected: Int = 0
    @Published var searchText = ""
    @Published private(set) var likedProductIds: Set<String> = []

    /// Разделы каталога: 0 — «Все», далее категории. Пусто, пока нет контента.
    var list: [ShopItemModel] { viewMode.content ?? [] }
    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var filteredList: [ShopItemModel] {
        list.map { $0.filtered(by: searchText) }
    }
    var favoriteProducts: [MainGrideDateModel] {
        (list.first?.product ?? []).filter { likedProductIds.contains($0.id) }
    }
    var favoritesViewMode: ViewMode<[MainGrideDateModel]> {
        switch viewMode {
        case .loading: return .loading
        case .content: return favoriteProducts.isEmpty ? .empty : .content(favoriteProducts)
        case .empty: return .empty
        case .noInternet: return .noInternet
        case .error(let message): return .error(message)
        }
    }

    private let network: NetworkMonitor
    private let defaults: UserDefaults
    private let favoritesKey: String?
    private var isRequestInFlight = false
    private var cancellables = Set<AnyCancellable>()
    #if DEBUG
    private var isPreview = false
    #endif

    init(network: NetworkMonitor = .shared,
         favoritesOwnerID: String? = AuthenticationService.currentUserID,
         defaults: UserDefaults = .standard) {
        self.network = network
        self.defaults = defaults
        favoritesKey = favoritesOwnerID.map { "favorites.\($0)" }
        if let favoritesKey {
            likedProductIds = Set(defaults.stringArray(forKey: favoritesKey) ?? [])
        }
        network.$isConnected
            .removeDuplicates()
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in self?.reloadAfterReconnect() }
            .store(in: &cancellables)
    }

    // MARK: - Загрузка

    #if DEBUG
    convenience init(previewProducts: [MainGrideDateModel], likedProductIDs: Set<String> = []) {
        self.init(favoritesOwnerID: nil)
        isPreview = true
        likedProductIds = likedProductIDs
        viewMode = .content([ShopItemModel(id: ShopItemModel.allCategory.id,
                                          categoryName: ShopItemModel.allCategory,
                                          product: previewProducts)])
    }
    #endif

    /// Первая загрузка. Если каталог уже показан — ничего не делает.
    func loadIfNeeded() {
        guard viewMode.content == nil else { return }
        reload()
    }

    /// Запрос каталога. Уже показанный каталог не заменяется спиннером или заглушкой ошибки.
    func reload(completion: (() -> Void)? = nil) {
        #if DEBUG
        if isPreview {
            completion?()
            return
        }
        #endif
        guard !isRequestInFlight else {
            completion?()
            return
        }
        guard network.isConnected else {
            if viewMode.content == nil { viewMode = .noInternet }
            completion?()
            return
        }
        if viewMode.content == nil { viewMode = .loading }
        isRequestInFlight = true

        FirestoreService.fetchCatalog { [weak self] result in
            self?.isRequestInFlight = false
            self?.apply(result.map(ShopItemModel.sections(from:)))
            completion?()
        }
    }

    /// Для `.refreshable`: ждёт ответа сервера.
    func refresh() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            reload { continuation.resume() }
        }
    }

    func product(id: String) -> MainGrideDateModel? {
        list.first?.product.first { $0.id == id }
    }

    func productViewMode(id: String) -> ViewMode<MainGrideDateModel> {
        switch viewMode {
        case .loading: return .loading
        case .content:
            return product(id: id).map { .content($0) } ?? .empty
        case .empty: return .empty
        case .noInternet: return .noInternet
        case .error(let message): return .error(message)
        }
    }

    // MARK: - Выбор и лайки

    func isSelected(_ index: Int) -> Bool {
        index == selected
    }

    func isLiked(_ product: MainGrideDateModel) -> Bool {
        likedProductIds.contains(product.id)
    }

    func toggleLike(_ product: MainGrideDateModel) {
        if likedProductIds.contains(product.id) {
            likedProductIds.remove(product.id)
        } else {
            likedProductIds.insert(product.id)
        }
        if let favoritesKey {
            defaults.set(likedProductIds.sorted(), forKey: favoritesKey)
        }
    }

    // MARK: - Private

    private func apply(_ result: Result<[ShopItemModel], Error>) {
        // Неудачное обновление не прячет каталог, который пользователь уже видит.
        if case .failure = result, viewMode.content != nil { return }

        viewMode = .make(from: result) { sections in
            sections.allSatisfy { $0.product.isEmpty }
        }
        if selected >= list.count { selected = 0 }
    }

    private func reloadAfterReconnect() {
        switch viewMode {
        case .noInternet, .error:
            reload()
        case .loading, .content, .empty:
            break
        }
    }
}
