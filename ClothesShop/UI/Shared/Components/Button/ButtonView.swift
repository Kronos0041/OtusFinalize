//
//  ButtonView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct ButtonView: View {
    let model: ButtonModel
    let state: ButtonState

    private var style: ButtonAppearance { state.style }

    var body: some View {
        HStack {
            Spacer()
            Text(model.title)
                .bold()
                .font(.system(size: ComponentConstants.Button.fontSize))
                .foregroundColor(style.foregroundColor)
            Spacer()
        }
        .frame(
            width: getWidth() - ComponentConstants.Layout.sideInset,
            height: ComponentConstants.Layout.buttonHeight
        )
        .background(style.background)
        .cornerRadius(ComponentConstants.Button.cornerRadius)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ButtonView(model: .signIn, state: .activeBlack)
                .previewLayout(.sizeThatFits)
                .previewThemes("Чёрная")
            ButtonView(model: .back, state: .activeWhite)
                .previewLayout(.sizeThatFits)
                .previewThemes("Белая")
        }
    }
}
