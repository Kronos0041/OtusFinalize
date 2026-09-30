//
//  NotificationsVM.swift
//  ClothesShop
//
//  Created by Alex on 28.09.2026.
//

import Foundation
import Combine

/// Уведомления и счётчик непрочитанных для колокольчика.
///
/// Уведомление становится прочитанным, когда пользователь на него нажал.
/// Прочитанные id хранятся в `UserDefaults`, поэтому бейдж не возвращается после перезапуска.
final class NotificationsVM: ObservableObject {
    @Published private(set) var viewMode: ViewMode<[NotificationItem]> = .loading
    @Published private(set) var readIds: Set<String>

    var unreadCount: Int {
        (viewMode.content ?? []).filter(isUnread).count
    }

    private let defaults: UserDefaults
    private let network: NetworkMonitor
    private var isRequestInFlight = false
    private var cancellables = Set<AnyCancellable>()
    private static let readIdsKey = "notifications.seenIds"

    init(defaults: UserDefaults = .standard, network: NetworkMonitor = .shared) {
        self.defaults = defaults
        self.network = network
        readIds = Set(defaults.stringArray(forKey: Self.readIdsKey) ?? [])

        network.$isConnected
            .removeDuplicates()
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in self?.reloadAfterReconnect() }
            .store(in: &cancellables)
    }

    // MARK: - Загрузка

    /// Загружает список. Уже показанный список обновляется тихо, без спиннера.
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

        FirestoreService.fetchNotifications { [weak self] result in
            self?.isRequestInFlight = false
            self?.apply(result)
            completion?()
        }
    }

    /// Для `.refreshable`: ждёт ответа сервера.
    func refresh() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            reload { continuation.resume() }
        }
    }

    // MARK: - Прочитанные

    func isUnread(_ item: NotificationItem) -> Bool {
        !readIds.contains(item.id)
    }

    /// Вызывается по нажатию на уведомление.
    func markRead(_ item: NotificationItem) {
        guard isUnread(item) else { return }
        readIds.insert(item.id)
        defaults.set(Array(readIds), forKey: Self.readIdsKey)
    }

    // MARK: - Private

    private func apply(_ result: Result<[NotificationItem], Error>) {
        if case .failure = result, viewMode.content != nil { return }
        let sorted = result.map { items in items.sorted { $0.remoteId < $1.remoteId } }
        viewMode = .make(from: sorted) { $0.isEmpty }
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
