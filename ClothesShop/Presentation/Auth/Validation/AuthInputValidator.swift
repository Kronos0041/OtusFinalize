import Foundation

struct AuthInputValidator {
    private let emailPredicate = NSPredicate(
        format: "SELF MATCHES %@",
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    )

    func isValidEmail(_ email: String) -> Bool { emailPredicate.evaluate(with: email) }

    func validationMessage(email: String, password: String, repeatPassword: String,
                           mode: AuthMode) -> String? {
        guard isValidEmail(email) else { return SwiftGen.Auth.Error.invalidEmail }
        guard !password.isEmpty else { return SwiftGen.Auth.Error.passwordRequired }
        guard mode == .registration else { return nil }
        guard password.count >= 6 else { return SwiftGen.Auth.Error.passwordTooShort(6) }
        guard password == repeatPassword else { return SwiftGen.Auth.Error.passwordMismatch }
        return nil
    }
}
