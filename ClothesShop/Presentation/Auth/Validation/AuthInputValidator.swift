import Foundation

struct AuthInputValidator {
    static let minimumPasswordLength = 6

    private let emailPredicate = NSPredicate(
        format: "SELF MATCHES %@",
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    )

    func isValidEmail(_ email: String) -> Bool { emailPredicate.evaluate(with: email) }

    /// Ошибка нового пароля при регистрации или `nil`, если пароль подходит.
    func newPasswordMessage(password: String, repeatPassword: String) -> String? {
        guard password.count >= Self.minimumPasswordLength else {
            return SwiftGen.Auth.Error.passwordTooShort(Self.minimumPasswordLength)
        }
        guard password == repeatPassword else { return SwiftGen.Auth.Error.passwordMismatch }
        return nil
    }
}
