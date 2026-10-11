import Foundation

extension RemoteDataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthorized: return SwiftGen.Network.Error.unauthorized
        case .permissionDenied: return SwiftGen.Network.Error.permissionDenied
        case .notFound: return SwiftGen.Network.Error.notFound
        case .quotaExceeded: return SwiftGen.Network.Error.quotaExceeded
        case .invalidData: return SwiftGen.Network.Error.invalidData
        case .unexpected: return SwiftGen.Network.Error.unexpected
        }
    }
}
