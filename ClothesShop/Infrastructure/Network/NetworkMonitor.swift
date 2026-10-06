import Foundation
import Network

final class NetworkMonitor: ConnectivityRepositoryProtocol {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "ClothesShop.NetworkMonitor")
    private var handlers: [UUID: (Bool) -> Void] = [:]
    private let lock = NSLock()
    private(set) var isConnected = true

    init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            DispatchQueue.main.async { self?.update(connected) }
        }
        monitor.start(queue: queue)
    }

    func observe(_ handler: @escaping (Bool) -> Void) -> ObservationToken {
        let id = UUID()
        lock.lock(); handlers[id] = handler; lock.unlock()
        return ObservationToken { [weak self] in
            self?.lock.lock(); self?.handlers.removeValue(forKey: id); self?.lock.unlock()
        }
    }

    private func update(_ connected: Bool) {
        guard isConnected != connected else { return }
        isConnected = connected
        lock.lock(); let currentHandlers = Array(handlers.values); lock.unlock()
        currentHandlers.forEach { $0(connected) }
    }

    deinit { monitor.cancel() }
}
