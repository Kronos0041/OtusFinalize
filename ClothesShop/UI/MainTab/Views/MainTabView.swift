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

    private var products: CatalogViewModel { viewModel.catalog }
    private var cart: CartViewModel { viewModel.cart }

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
            CatalogView(
                notifications: notificationsViewModel,
                openCart: { selected = .cart }
            )
                .tabItem { Label(SwiftGen.Catalog.title, systemImage: "house") }
                .tag(Tab.products)

            FavoritesView()
                .tabItem { Label(SwiftGen.Favorites.title, systemImage: "heart") }
                .tag(Tab.favorites)

            CartView(continueShopping: { selected = .products }, reload: viewModel.reloadCart)
                .tabItem { Label(SwiftGen.Cart.title, systemImage: "bag") }
                .badge(cart.count)
                .tag(Tab.cart)

            ProfileView(viewModel: profileViewModel)
                .tabItem { Label(SwiftGen.Profile.title, systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .environment(products)
        .environment(cart)
        .environment(\.imageLoadMaxAttempts, viewModel.imageLoadMaxAttempts)
        .tint(.appBlack)
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

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = UIColor(Color.appWhite)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#if DEBUG
/// Пустые состояния без запросов к Firebase.
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppDIContainer.shared
        let viewModel = container.makeMainTabViewModel()
        viewModel.catalog.applyCatalog(.success(Catalog(categories: [], products: [])))
        let notifications = container.makeNotificationsViewModel()
        notifications.applyPreview(items: [])
        let profile = container.makeProfileViewModel()
        profile.applyPreview(profile: UserProfile(email: "preview@example.com"))
        return MainTabView(viewModel: viewModel, notificationsViewModel: notifications, profileViewModel: profile)
            .previewThemes()
    }
}
#endif
