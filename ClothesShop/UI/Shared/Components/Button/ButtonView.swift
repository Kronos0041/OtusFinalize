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
    var frame: (width: CGFloat, height: CGFloat) = AppLayout.fullWidthButton
    var imageLeft: String? = nil
    var imageRight: String? = nil

    private var style: ButtonAppearance { state.style }

    var body: some View {
        HStack {
            Spacer()
            icon(imageLeft)
            Text(model.title)
                .bold()
                .font(.system(size: 18))
                .foregroundColor(style.foregroundColor)
            icon(imageRight)
            Spacer()
        }
        .frame(width: frame.width, height: frame.height)
        .background(style.background)
        .cornerRadius(10)
    }

    @ViewBuilder
    private func icon(_ name: String?) -> some View {
        if let name = name {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(style.foregroundColor)
                .background(style.background)
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(model: .ok,
                   state: .activeBlack,
                   frame: (340, 50),
                   imageLeft: AppImage.Icon.next,
                   imageRight: AppImage.Icon.next)
            .previewThemes()
    }
}
