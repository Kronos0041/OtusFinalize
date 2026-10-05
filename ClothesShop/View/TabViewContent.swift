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
        case favorites
        case cart
        case profile
    }

    @State private var selected: Tab = .products
    @StateObject private var products = MainGrideVM()
    @StateObject private var cart = CartVM()

    var body: some View {
        TabView(selection: $selected) {
            MainView()
                .tabItem { tabLabel(title: SwiftGen.Catalog.title, systemImage: "house") }
                .tag(Tab.products)

            FavoritesView()
                .tabItem { tabLabel(title: SwiftGen.Favorites.title, systemImage: "heart") }
                .tag(Tab.favorites)

            CartView { selected = .products }
                .tabItem { tabLabel(title: SwiftGen.Cart.title, systemImage: "bag") }
                .badge(cart.count)
                .tag(Tab.cart)

            ProfileView()
                .tabItem { tabLabel(title: SwiftGen.Profile.title, systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .environmentObject(products)
        .environmentObject(cart)
        .accentColor(Color.appBlack)
        .onAppear(perform: Self.configureTabBarAppearance)
    }

    private func tabLabel(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
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
            .previewThemes()
    }
}
