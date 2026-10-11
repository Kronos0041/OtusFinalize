import FirebaseAuth

enum FirebaseAuthErrorMapper {
    static func map(_ error: Error) -> Error {
        let error = error as NSError
        guard error.domain == AuthErrorDomain else { return error }
        switch AuthErrorCode(rawValue: error.code) {
        case .wrongPassword: return AuthRepositoryError.wrongPassword
        case .invalidCredential, .userNotFound: return AuthRepositoryError.invalidCredentials
        case .userDisabled: return AuthRepositoryError.accountDisabled
        case .emailAlreadyInUse: return AuthRepositoryError.emailAlreadyInUse
        case .invalidEmail: return AuthRepositoryError.invalidEmail
        case .weakPassword: return AuthRepositoryError.weakPassword
        case .networkError: return ConnectivityError.offline
        case .tooManyRequests: return AuthRepositoryError.tooManyRequests
        case .requiresRecentLogin, .invalidUserToken, .userTokenExpired:
            return AuthRepositoryError.sessionExpired
        default: return AuthRepositoryError.unexpected
        }
    }
}
