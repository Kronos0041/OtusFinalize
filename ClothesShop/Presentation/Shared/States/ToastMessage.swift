/// Короткое уведомление для `ToastView`: текст и его смысл. Иконку по смыслу выбирает UI.
struct ToastMessage: Equatable {
    enum Kind {
        /// Что-то пошло не так.
        case error
        /// Действие выполнено.
        case success
        /// Просто сообщение, например «пока в разработке».
        case info
    }

    let text: String
    let kind: Kind

    static func error(_ text: String) -> ToastMessage { ToastMessage(text: text, kind: .error) }
    static func success(_ text: String) -> ToastMessage { ToastMessage(text: text, kind: .success) }
    static func info(_ text: String) -> ToastMessage { ToastMessage(text: text, kind: .info) }
}
