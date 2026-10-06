import SwiftUI

enum ButtonState {
    case activeBlack
    case activeWhite
    case disable

    var style: ButtonAppearance {
        switch self {
        case .activeBlack:
            return ButtonAppearance(background: .appBlack, foregroundColor: .appWhite,
                                    borderColor: .appBlack)
        case .activeWhite:
            return ButtonAppearance(background: .appWhite, foregroundColor: .appBlack,
                                    borderColor: .appBlack)
        case .disable:
            return ButtonAppearance(background: .appGray, foregroundColor: .appWhite,
                                    borderColor: .appGray)
        }
    }
}
