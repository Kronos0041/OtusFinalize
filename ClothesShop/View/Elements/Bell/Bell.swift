//
//  Bell.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct BellView: View {
    let notificationCount: Int

    private var badgeText: String {
        notificationCount > 99 ? "99+" : "\(notificationCount)"
    }

    var body: some View {
        ZStack {
            Image(systemName: "bell")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            if notificationCount > 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text(badgeText)
                            .bold()
                            .font(.system(size: 8))
                            .foregroundColor(Color.appWhite)
                            .frame(width: 20, height: 20)
                            .background(.red)
                            .cornerRadius(10)
                            .offset(x: 3, y: -8)
                    }
                    Spacer()
                }
                .frame(width: 30, height: 30)
            }
        }
        .frame(width: 30, height: 30)
    }
}

struct BellBellView_Previews: PreviewProvider {
    static var previews: some View {
        BellView(notificationCount: 1)
            .previewThemes()
    }
}
