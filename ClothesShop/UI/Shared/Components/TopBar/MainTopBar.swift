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
                .frame(width: 160, height: 40)
                .accessibilityLabel(Text(verbatim: "Montblanc"))

            HStack(spacing: 16) {
                Spacer()

                Button(action: clickBell) {
                    BellView(notificationCount: notificationCount)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(SwiftGen.Notifications.title))

                Button(action: clickCart) {
                    Image(systemName: "bag")
                        .font(.system(size: 26, weight: .regular))
                        .frame(width: 36, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(SwiftGen.Cart.title))
            }
        }
        .foregroundColor(.appBlack)
        .frame(width: getWidth() - AppLayout.sideInset, height: 56)
    }
}

struct MainTopBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTopBar(notificationCount: 3, clickBell: {}, clickCart: {})
            .previewThemes()
    }
}
