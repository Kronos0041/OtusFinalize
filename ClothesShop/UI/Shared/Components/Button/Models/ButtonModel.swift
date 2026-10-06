enum ButtonModel {
    case ok
    case back
    case next
    case addToCart
    case signIn
    case registration

    var title: String {
        switch self {
        case .ok: return SwiftGen.Common.ok
        case .back: return SwiftGen.Common.back
        case .next: return SwiftGen.Common.next
        case .addToCart: return SwiftGen.Common.add
        case .signIn: return SwiftGen.Auth.authorization
        case .registration: return SwiftGen.Auth.signUp
        }
    }
}
