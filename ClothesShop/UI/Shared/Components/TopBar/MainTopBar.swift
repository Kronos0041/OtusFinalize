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

    var body: some View {
        ZStack {
            Image(AppImage.brandWordmark)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: ComponentConstants.TopBar.wordmarkSize.width, height: ComponentConstants.TopBar.wordmarkSize.height)
                .accessibilityLabel(Text(verbatim: "Montblanc"))

            HStack {
                Spacer()

                Button(action: clickBell) {
                    BellView(notificationCount: notificationCount)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(SwiftGen.Notifications.title))
            }
        }
        .foregroundColor(.appBlack)
        .frame(width: getWidth() - ComponentConstants.Layout.sideInset, height: ComponentConstants.TopBar.mainHeight)
    }
}

struct MainTopBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTopBar(notificationCount: 3, clickBell: {})
            .previewThemes()
    }
}
