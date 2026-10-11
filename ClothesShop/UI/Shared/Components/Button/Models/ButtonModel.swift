enum ButtonModel {
    case back
    case signIn
    case registration

    var title: String {
        switch self {
        case .back: return SwiftGen.Common.back
        case .signIn: return SwiftGen.Auth.authorization
        case .registration: return SwiftGen.Auth.signUp
        }
    }
}
