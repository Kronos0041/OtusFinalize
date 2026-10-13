#if DEBUG
import Foundation

/// Фиксированное состояние сети: `false` даёт экраны «нет интернета».
struct MockConnectivityRepository: ConnectivityRepositoryProtocol {
    let isConnected: Bool

    func updates() -> AsyncStream<Bool> {
        AsyncStream { $0.finish() }
    }
}
#endif
