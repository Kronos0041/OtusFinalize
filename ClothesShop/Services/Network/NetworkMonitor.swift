//
//  NetworkMonitor.swift
//  ClothesShop
//
//  Created by Alex on 29.09.2026.
//

import Foundation
import Network

/// Доступность сети на устройстве (`NWPathMonitor`). Изменения публикуются на главном потоке.
///
/// Firestore без сети может отдать пустой кэш вместо ошибки, поэтому ViewModel
/// проверяет соединение до запроса и повторяет загрузку, когда сеть вернулась.
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                guard let self, self.isConnected != isConnected else { return }
                self.isConnected = isConnected
            }
        }
        monitor.start(queue: DispatchQueue(label: "ClothesShop.NetworkMonitor"))
    }

    deinit {
        monitor.cancel()
    }
}
