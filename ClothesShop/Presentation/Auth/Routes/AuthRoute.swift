/// Экраны стека авторизации поверх стартового экрана.
enum AuthRoute: Hashable {
    /// Форма входа или регистрации.
    case form(AuthMode)
}
