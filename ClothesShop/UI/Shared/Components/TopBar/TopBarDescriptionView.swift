//
//  TopBarDescriptionView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct TopBarDescriptionView: View {
    let title: String
    @Binding var backButton: Bool
    let frame: (width: CGFloat, height: CGFloat)

    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .padding()
                    .foregroundColor(Color.appBlack)
                    .accessibilityLabel(Text(SwiftGen.Common.back))
                    .onTapGesture { backButton.toggle() }
                Spacer()
            }

            Text(title)
                .bold()
                .font(.system(size: 24, design: .serif))
                .foregroundColor(Color.appBlack)
        }
        .frame(width: frame.width, height: frame.height)
    }
}

struct TopBarDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarDescriptionView(title: SwiftGen.Product.title, backButton: .constant(false), frame: (width: 300, height: 50))
            .previewThemes()
    }
}
