import Foundation

extension AuthRepositoryError: LocalizedError {
    var errorDescription: String? {
        AuthErrorMessageMapper.message(for: self)
    }
}
