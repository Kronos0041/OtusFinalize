import SwiftUI

enum ButtonState {
    case activeBlack
    case activeWhite
    /// Неактивная основная кнопка: действие пока недоступно.
    case disabled

    var style: ButtonAppearance {
        switch self {
        case .activeBlack:
            return ButtonAppearance(background: .appBlack, foregroundColor: .appWhite)
        case .activeWhite:
            return ButtonAppearance(background: .appWhite, foregroundColor: .appBlack)
        case .disabled:
            return ButtonAppearance(background: .appGray, foregroundColor: .appWhite)
        }
    }
}
