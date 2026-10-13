/// Экраны стека авторизации поверх ввода email.
enum AuthRoute: Hashable {
    /// Аккаунт есть: ввод пароля.
    case password
    /// Аккаунта нет: придумать пароль.
    case createPassword
}
