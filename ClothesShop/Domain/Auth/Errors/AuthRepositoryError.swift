/// Ошибки авторизации и управления аккаунтом.
/// Тексты для пользователя задаёт Presentation (`AuthRepositoryError+LocalizedError`).
enum AuthRepositoryError: Error, Equatable {
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
}
