//
//  TabViewContent.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Корневой таб-бар после авторизации.
struct TabViewContent: View {
    private enum Tab: Int {
        case products
        case profile
    }

    @State private var selected: Tab = .products

    var body: some View {
        TabView(selection: $selected) {
            MainView()
                .tabItem { tabLabel(title: "Товары", systemImage: "basket") }
                .tag(Tab.products)

            ProfileView()
                .tabItem { tabLabel(title: "Профиль", systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .accentColor(Color.appBlack)
        .onAppear(perform: Self.configureTabBarAppearance)
    }

    private func tabLabel(title: LocalizedStringKey, systemImage: String) -> some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .foregroundColor(Color.appWhite)
            Text(title)
                .foregroundColor(Color.appBlack)
        }
    }

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = UIColor(Color.appWhite)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct TabViewContent_Previews: PreviewProvider {
    static var previews: some View {
        TabViewContent()
    }
}
