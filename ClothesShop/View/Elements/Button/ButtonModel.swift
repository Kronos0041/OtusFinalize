//
//  ButtonModels.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

enum ButtonModel {
    case ok
    case back
    case next
    case magazin
    case auth
    case reg

    var title: String {
        switch self {
        case .ok: return SwiftGen.Common.ok
        case .back: return SwiftGen.Common.back
        case .next: return SwiftGen.Common.next
        case .magazin: return SwiftGen.Common.add
        case .auth: return SwiftGen.Auth.authorization
        case .reg: return SwiftGen.Auth.signUp
        }
    }
}

enum ButtonState {
    case activeBlack
    case activeWhite
    case disable

    var style: ButtonAppearance {
        switch self {
        case .activeBlack:
            return ButtonAppearance(background: Color.appBlack, foregroundColor: Color.appWhite, borderColor: Color.appBlack)
        case .activeWhite:
            return ButtonAppearance(background: Color.appWhite, foregroundColor: Color.appBlack, borderColor: Color.appBlack)
        case .disable:
            return ButtonAppearance(background: Color.appGray, foregroundColor: Color.appWhite, borderColor: Color.appGray)
        }
    }
}

/// Раньше называлось `ButtonStyle` и затеняло протокол `SwiftUI.ButtonStyle`.
struct ButtonAppearance {
    let background: Color
    let foregroundColor: Color
    let borderColor: Color
}
