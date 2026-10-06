import Foundation

/// Удерживает внешнюю подписку (Firebase, NWPathMonitor) активной и отменяет её при освобождении токена.
final class ObservationToken {
    private var cancellation: (() -> Void)?

    init(cancellation: @escaping () -> Void) {
        self.cancellation = cancellation
    }

    func cancel() {
        cancellation?()
        cancellation = nil
    }

    deinit {
        cancel()
    }
}
