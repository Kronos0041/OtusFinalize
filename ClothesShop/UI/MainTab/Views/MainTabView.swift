//
//  MainTabView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Корневой таб-бар после авторизации.
struct MainTabView: View {
    private enum Tab: Int {
        case products
        case favorites
        case cart
        case profile
    }

    @State private var selected: Tab = .products
    private let container: AppDIContainer
    @StateObject private var viewModel: MainTabViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    private var products: CatalogViewModel { viewModel.catalog }
    private var cart: CartViewModel { viewModel.cart }

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = StateObject(wrappedValue: container.makeMainTabViewModel())
        _profileViewModel = StateObject(wrappedValue: container.makeProfileViewModel())
    }

    var body: some View {
        TabView(selection: $selected) {
            CatalogView(notificationsViewModel: container.makeNotificationsViewModel())
                .tabItem { tabLabel(title: SwiftGen.Catalog.title, systemImage: "house") }
                .tag(Tab.products)

            FavoritesView()
                .tabItem { tabLabel(title: SwiftGen.Favorites.title, systemImage: "heart") }
                .tag(Tab.favorites)

            CartView { selected = .products }
                .tabItem { tabLabel(title: SwiftGen.Cart.title, systemImage: "bag") }
                .badge(cart.count)
                .tag(Tab.cart)

            ProfileView(viewModel: profileViewModel)
                .tabItem { tabLabel(title: SwiftGen.Profile.title, systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .environmentObject(products)
        .environmentObject(cart)
        .accentColor(Color.appBlack)
        .onAppear {
            Self.configureTabBarAppearance()
            viewModel.loadIfNeeded()
        }
        .alert(SwiftGen.Network.loadFailed, isPresented: Binding(
            get: { cart.errorMessage != nil },
            set: { if !$0 { cart.dismissError() } }
        )) {
            Button(SwiftGen.Common.ok, role: .cancel, action: cart.dismissError)
        } message: {
            Text(verbatim: cart.errorMessage ?? "")
        }
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

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(container: .shared)
            .previewThemes()
    }
}
