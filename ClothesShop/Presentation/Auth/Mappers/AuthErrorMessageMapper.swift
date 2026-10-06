enum AuthErrorMessageMapper {
    static func message(for error: Error, verifyingCurrentPassword: Bool = true) -> String {
        if error is ConnectivityError { return SwiftGen.Network.offline }
        guard let error = error as? AuthRepositoryError else { return error.localizedDescription }
        switch error {
        case .missingUser: return SwiftGen.Auth.Error.sessionEnded
        case .wrongPassword:
            return verifyingCurrentPassword ? SwiftGen.Auth.Error.wrongPassword : SwiftGen.Auth.Error.invalidCredentials
        case .invalidCredentials: return SwiftGen.Auth.Error.invalidCredentials
        case .accountDisabled: return SwiftGen.Auth.Error.accountDisabled
        case .emailAlreadyInUse: return SwiftGen.Auth.Error.emailInUse
        case .invalidEmail: return SwiftGen.Auth.Error.invalidEmail
        case .weakPassword: return SwiftGen.Auth.Error.weakPassword
        case .tooManyRequests: return SwiftGen.Auth.Error.tooManyRequests
        case .sessionExpired: return SwiftGen.Auth.Error.sessionExpired
        case .unexpected: return SwiftGen.Auth.Error.unexpected
        }
    }
}
