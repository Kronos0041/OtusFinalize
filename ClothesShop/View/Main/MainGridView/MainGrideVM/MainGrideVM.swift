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
    @Published private(set) var likedProductIds: Set<String> = []

    /// Разделы каталога: 0 — «Все», далее категории. Пусто, пока нет контента.
    var list: [ShopItemModel] { viewMode.content ?? [] }

    private let network: NetworkMonitor
    private var isRequestInFlight = false
    private var cancellables = Set<AnyCancellable>()

    init(network: NetworkMonitor = .shared) {
        self.network = network
        network.$isConnected
            .removeDuplicates()
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in self?.reloadAfterReconnect() }
            .store(in: &cancellables)
    }

    // MARK: - Загрузка

    /// Первая загрузка. Если каталог уже показан — ничего не делает.
    func loadIfNeeded() {
        guard viewMode.content == nil else { return }
        reload()
    }

    /// Запрос каталога. Уже показанный каталог не заменяется спиннером или заглушкой ошибки.
    func reload(completion: (() -> Void)? = nil) {
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
