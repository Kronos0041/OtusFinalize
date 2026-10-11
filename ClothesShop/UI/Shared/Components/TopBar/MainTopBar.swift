//
//  MainTopBar.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct MainTopBar: View {
    let notificationCount: Int
    let clickBell: () -> Void
    let clickCart: () -> Void

    var body: some View {
        ZStack {
            Image(AppImage.brandWordmark)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: ComponentConstants.TopBar.wordmarkSize.width, height: ComponentConstants.TopBar.wordmarkSize.height)
                .accessibilityLabel(Text(verbatim: "Montblanc"))

            HStack(spacing: ComponentConstants.TopBar.actionsSpacing) {
                Spacer()

                Button(action: clickBell) {
                    BellView(notificationCount: notificationCount)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(SwiftGen.Notifications.title))

                Button(action: clickCart) {
                    Image(systemName: "bag")
                        .font(.system(size: ComponentConstants.TopBar.cartIconFontSize, weight: .regular))
                        .frame(width: ComponentConstants.TopBar.cartButtonSize.width, height: ComponentConstants.TopBar.cartButtonSize.height)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(SwiftGen.Cart.title))
            }
        }
        .foregroundColor(.appBlack)
        .frame(width: getWidth() - AppLayout.sideInset, height: ComponentConstants.TopBar.mainHeight)
    }
}

struct MainTopBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTopBar(notificationCount: 3, clickBell: {}, clickCart: {})
            .previewThemes()
    }
}
