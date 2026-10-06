import SwiftUI

enum ButtonState {
    case activeBlack
    case activeWhite

    var style: ButtonAppearance {
        switch self {
        case .activeBlack:
            return ButtonAppearance(background: .appBlack, foregroundColor: .appWhite)
        case .activeWhite:
            return ButtonAppearance(background: .appWhite, foregroundColor: .appBlack)
        }
    }
}
