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
    @State private var viewModel: MainTabViewModel
    @State private var notificationsViewModel: NotificationsViewModel
    @State private var profileViewModel: ProfileViewModel

    private var catalogViewModel: CatalogViewModel { viewModel.catalogViewModel }
    private var cartViewModel: CartViewModel { viewModel.cartViewModel }

    init(container: AppDIContainer) {
        self.init(viewModel: container.makeMainTabViewModel(),
                  notificationsViewModel: container.makeNotificationsViewModel(),
                  profileViewModel: container.makeProfileViewModel())
    }

    /// SwiftUI сохраняет ViewModel из первого создания экрана; при повторной инициализации
    /// `MainTabView` родителем новые экземпляры отбрасываются. Поэтому init ViewModel не делает запросов.
    init(viewModel: MainTabViewModel,
         notificationsViewModel: NotificationsViewModel,
         profileViewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
        _notificationsViewModel = State(initialValue: notificationsViewModel)
        _profileViewModel = State(initialValue: profileViewModel)
    }

    var body: some View {
        TabView(selection: $selected) {
            CatalogView(notificationsViewModel: notificationsViewModel)
                .tabItem { Label(SwiftGen.Catalog.title, systemImage: "house") }
                .tag(Tab.products)

            FavoritesView()
                .tabItem { Label(SwiftGen.Favorites.title, systemImage: "heart") }
                .tag(Tab.favorites)

            CartView(continueShopping: { selected = .products }, reload: viewModel.reloadCart)
                .tabItem { Label(SwiftGen.Cart.title, systemImage: "bag") }
                .badge(cartViewModel.count)
                .tag(Tab.cart)

            ProfileView(viewModel: profileViewModel)
                .tabItem { Label(SwiftGen.Profile.title, systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .environment(catalogViewModel)
        .environment(cartViewModel)
        .environment(\.imageLoadMaxAttempts, viewModel.imageLoadMaxAttempts)
        .tint(.appBlack)
        .onAppear {
            Self.configureTabBarAppearance()
            viewModel.loadIfNeeded()
        }
        .alert(SwiftGen.Network.loadFailed, isPresented: Binding(
            get: { cartViewModel.errorMessage != nil },
            set: { if !$0 { cartViewModel.dismissError() } }
        )) {
            Button(SwiftGen.Common.ok, role: .cancel, action: cartViewModel.dismissError)
        } message: {
            Text(verbatim: cartViewModel.errorMessage ?? "")
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

#if DEBUG
/// Данные из mock-репозиториев, без запросов к Firebase.
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(container: .mock())
            .previewThemes()
    }
}
#endif
