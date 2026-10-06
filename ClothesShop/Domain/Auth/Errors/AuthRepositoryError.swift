import Foundation

enum AuthRepositoryError: LocalizedError {
    case missingUser
    case wrongPassword
    case invalidCredentials
    case accountDisabled
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case tooManyRequests
    case sessionExpired
    case unexpected

    var errorDescription: String? {
        String(describing: self)
    }
}
