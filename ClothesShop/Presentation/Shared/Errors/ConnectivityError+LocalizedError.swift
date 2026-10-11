import Foundation

extension ConnectivityError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .offline: return SwiftGen.Network.offline
        case .serverUnavailable: return SwiftGen.Network.serverUnavailable
        }
    }
}
