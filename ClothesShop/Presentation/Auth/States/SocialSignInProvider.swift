/// Внешние способы входа. Пока не подключены: кнопки показывают уведомление «в разработке».
enum SocialSignInProvider: CaseIterable {
    case apple
    case facebook
    case google

    var name: String {
        switch self {
        case .apple: return "Apple"
        case .facebook: return "Facebook"
        case .google: return "Google"
        }
    }
}
