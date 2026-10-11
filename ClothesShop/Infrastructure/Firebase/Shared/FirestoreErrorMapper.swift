import FirebaseFirestore

/// Переводит ошибки Firestore и сетевого стека в доменные ошибки.
/// Остальные ошибки возвращаются без изменений.
enum FirestoreErrorMapper {
    private static let connectivityURLErrorCodes: Set<Int> = [
        NSURLErrorNotConnectedToInternet,
        NSURLErrorNetworkConnectionLost,
        NSURLErrorTimedOut,
        NSURLErrorCannotConnectToHost,
        NSURLErrorDataNotAllowed
    ]

    static func map(_ error: Error) -> Error {
        let nsError = error as NSError
        switch nsError.domain {
        case NSURLErrorDomain where connectivityURLErrorCodes.contains(nsError.code):
            return ConnectivityError.offline
        case FirestoreErrorDomain where nsError.code == FirestoreErrorCode.Code.unavailable.rawValue:
            return ConnectivityError.offline
        default:
            return error
        }
    }
}
