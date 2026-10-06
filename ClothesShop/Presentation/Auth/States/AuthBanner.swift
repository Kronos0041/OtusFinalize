struct AuthBanner: Equatable {
    var message: String
    var isVisible: Bool

    static let hidden = AuthBanner(message: "", isVisible: false)
    static func error(_ message: String) -> AuthBanner {
        AuthBanner(message: message, isVisible: true)
    }
}
