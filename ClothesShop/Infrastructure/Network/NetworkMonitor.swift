import Foundation
import Network

/// Отслеживает доступность сети. С iOS 17 `NWPathMonitor` — это `AsyncSequence`,
/// поэтому и текущее состояние, и подписки читаются обычным `for await`.
final class NetworkMonitor: ConnectivityRepositoryProtocol {
    private(set) var isConnected = true
    private var monitoringTask: Task<Void, Never>?

    init() {
        // Состояние обновляется в главном потоке: его читают ViewModel перед запросами.
        monitoringTask = Task { @MainActor [weak self] in
            for await path in NWPathMonitor() {
                self?.isConnected = path.status == .satisfied
            }
        }
    }

    deinit {
        monitoringTask?.cancel()
    }

    /// Каждая подписка получает свой монитор; он останавливается, когда подписчик отменяет задачу.
    /// Повторяющиеся значения отбрасываются — приходят только изменения.
    func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                var lastValue: Bool?
                for await path in NWPathMonitor() {
                    let connected = path.status == .satisfied
                    guard connected != lastValue else { continue }
                    lastValue = connected
                    continuation.yield(connected)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
