import FirebaseFirestore

/// Переводит ошибки Firestore и сетевого стека в доменные ошибки.
/// Ошибки других доменов (уже доменные или `CancellationError`) пропускаются без изменений.
enum FirestoreErrorMapper {
    private static let offlineURLErrorCodes: Set<Int> = [
        NSURLErrorNotConnectedToInternet,
        NSURLErrorNetworkConnectionLost,
        NSURLErrorDataNotAllowed,
        NSURLErrorInternationalRoamingOff
    ]

    private static let serverUnavailableURLErrorCodes: Set<Int> = [
        NSURLErrorTimedOut,
        NSURLErrorCannotConnectToHost,
        NSURLErrorCannotFindHost,
        NSURLErrorDNSLookupFailed
    ]

    static func map(_ error: Error) -> Error {
        if error is DecodingError { return RemoteDataError.invalidData }

        let nsError = error as NSError
        switch nsError.domain {
        case NSURLErrorDomain:
            return mapURLError(code: nsError.code)
        case FirestoreErrorDomain:
            return mapFirestoreError(code: FirestoreErrorCode.Code(rawValue: nsError.code))
        default:
            return error
        }
    }

    private static func mapURLError(code: Int) -> Error {
        if offlineURLErrorCodes.contains(code) { return ConnectivityError.offline }
        if serverUnavailableURLErrorCodes.contains(code) { return ConnectivityError.serverUnavailable }
        if code == NSURLErrorCancelled { return CancellationError() }
        return RemoteDataError.unexpected
    }

    private static func mapFirestoreError(code: FirestoreErrorCode.Code?) -> Error {
        switch code {
        // Firestore возвращает `unavailable`, когда нет сети или сервис временно недоступен.
        case .unavailable: return ConnectivityError.offline
        case .deadlineExceeded: return ConnectivityError.serverUnavailable
        case .cancelled: return CancellationError()
        case .unauthenticated: return RemoteDataError.unauthorized
        case .permissionDenied: return RemoteDataError.permissionDenied
        case .notFound: return RemoteDataError.notFound
        case .resourceExhausted: return RemoteDataError.quotaExceeded
        case .dataLoss, .invalidArgument, .outOfRange: return RemoteDataError.invalidData
        default: return RemoteDataError.unexpected
        }
    }
}
