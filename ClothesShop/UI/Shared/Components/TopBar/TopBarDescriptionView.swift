//
//  TopBarDescriptionView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct TopBarDescriptionView: View {
    let title: String
    let onBack: () -> Void
    let frame: (width: CGFloat, height: CGFloat)

    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: ComponentConstants.TopBar.backIconSize, height: ComponentConstants.TopBar.backIconSize)
                    .padding()
                    .foregroundColor(Color.appBlack)
                    .accessibilityLabel(Text(SwiftGen.Common.back))
                    .onTapGesture(perform: onBack)
                Spacer()
            }

            Text(title)
                .bold()
                .font(.system(size: ComponentConstants.TopBar.titleFontSize, design: .serif))
                .foregroundColor(Color.appBlack)
        }
        .frame(width: frame.width, height: frame.height)
    }
}

struct TopBarDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarDescriptionView(title: SwiftGen.Product.title, onBack: {}, frame: (width: 300, height: 50))
            .previewThemes()
    }
}
