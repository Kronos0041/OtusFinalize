//
//  BellView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct BellView: View {
    let notificationCount: Int

    private var badgeText: String {
        notificationCount > ComponentConstants.Bell.maxBadgeCount ? "\(ComponentConstants.Bell.maxBadgeCount)+" : "\(notificationCount)"
    }

    var body: some View {
        ZStack {
            Image(systemName: "bell")
                .resizable()
                .scaledToFit()
                .frame(width: ComponentConstants.Bell.iconSize, height: ComponentConstants.Bell.iconSize)

            if notificationCount > 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text(badgeText)
                            .bold()
                            .font(.system(size: ComponentConstants.Bell.badgeFontSize))
                            .foregroundColor(Color.appWhite)
                            .frame(width: ComponentConstants.Bell.badgeSize, height: ComponentConstants.Bell.badgeSize)
                            .background(.red)
                            .cornerRadius(ComponentConstants.Bell.badgeSize / 2)
                            .offset(ComponentConstants.Bell.badgeOffset)
                    }
                    Spacer()
                }
                .frame(width: ComponentConstants.Bell.iconSize, height: ComponentConstants.Bell.iconSize)
            }
        }
        .frame(width: ComponentConstants.Bell.iconSize, height: ComponentConstants.Bell.iconSize)
    }
}

struct BellView_Previews: PreviewProvider {
    static var previews: some View {
        BellView(notificationCount: 1)
            .previewThemes()
    }
}
