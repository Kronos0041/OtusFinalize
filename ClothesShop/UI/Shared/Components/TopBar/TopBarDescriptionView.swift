//
//  TopBarDescriptionView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Шапка экрана: «назад» слева, заголовок по центру, необязательное действие справа.
struct TopBarDescriptionView<Trailing: View>: View {
    let title: String
    let onBack: () -> Void
    let frame: (width: CGFloat, height: CGFloat)
    @ViewBuilder var trailing: () -> Trailing

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
                trailing()
                    .padding(.trailing)
            }

            Text(title)
                .bold()
                .font(.system(size: ComponentConstants.TopBar.titleFontSize, design: .serif))
                .foregroundColor(Color.appBlack)
        }
        .frame(width: frame.width, height: frame.height)
    }
}

extension TopBarDescriptionView where Trailing == EmptyView {
    init(title: String, onBack: @escaping () -> Void, frame: (width: CGFloat, height: CGFloat)) {
        self.init(title: title, onBack: onBack, frame: frame) { EmptyView() }
    }
}

struct TopBarDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarDescriptionView(title: SwiftGen.Product.title, onBack: {}, frame: (width: 300, height: 50))
            .previewThemes()
    }
}
