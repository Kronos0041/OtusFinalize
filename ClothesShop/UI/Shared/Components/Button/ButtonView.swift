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
    /// Вместо заголовка — индикатор загрузки, пока идёт запрос.
    var isLoading = false

    private var style: ButtonAppearance { state.style }

    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView()
                    .tint(style.foregroundColor)
            } else {
                Text(model.title)
                    .bold()
                    .font(.system(size: ComponentConstants.Button.fontSize))
                    .foregroundColor(style.foregroundColor)
            }
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
            ButtonView(model: .continueAction, state: .activeBlack)
                .previewLayout(.sizeThatFits)
                .previewThemes("Чёрная")
            ButtonView(model: .continueAction, state: .activeWhite)
                .previewLayout(.sizeThatFits)
                .previewThemes("Белая")
        }
    }
}
