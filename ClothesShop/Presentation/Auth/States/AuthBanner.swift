struct AuthBanner: Equatable {
    let message: String
    let isVisible: Bool

    /// Скрытый баннер с тем же текстом: сообщение не пропадает раньше анимации скрытия.
    var dismissed: AuthBanner {
        AuthBanner(message: message, isVisible: false)
    }

    static let hidden = AuthBanner(message: "", isVisible: false)
    static func error(_ message: String) -> AuthBanner {
        AuthBanner(message: message, isVisible: true)
    }
}
