enum ButtonModel {
    case continueAction
    case emailConfirmed

    var title: String {
        switch self {
        case .continueAction: return SwiftGen.Common.continue
        case .emailConfirmed: return SwiftGen.Auth.Verification.check
        }
    }
}
