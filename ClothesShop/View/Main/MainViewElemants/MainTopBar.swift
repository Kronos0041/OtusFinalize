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
        HStack {
            Text("Montblanc")
                .bold()
                .font(.system(size: 34, design: .serif))

            Spacer()

            BellView(notificationCount: notificationCount)
                .onTapGesture(perform: clickBell)
        }
        .frame(width: getWidth() - AppLayout.sideInset, height: 50)
    }
}

struct MainTopBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTopBar(notificationCount: 0) {}
    }
}
