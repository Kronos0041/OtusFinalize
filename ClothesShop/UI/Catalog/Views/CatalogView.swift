//
//  CatalogView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Вкладка «Товары»: шапка с колокольчиком и каталог.
struct CatalogView: View {
    @Environment(CatalogViewModel.self) private var products
    /// Владеет ViewModel уведомлений `MainTabView`; здесь только наблюдение.
    let notifications: NotificationsViewModel
    let openCart: () -> Void
    @State private var router = Router<CatalogRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 15) {
                MainTopBar(
                    notificationCount: notifications.unreadCount,
                    clickBell: { router.push(.notifications) },
                    clickCart: openCart
                )

                ViewModeView(
                    products.mode,
                    emptyTitle: SwiftGen.Catalog.empty,
                    retry: { products.reload() }
                ) { _ in
                    CatalogSectionTabsView()
                }
            }
            .frame(width: getWidth())
            .toolbar(.hidden, for: .navigationBar)
            .catalogDestinations(notifications: notifications)
        }
        .environment(router)
        .onAppear {
            notifications.reload()
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView(
            notifications: AppDIContainer.shared.makeNotificationsViewModel(),
            openCart: {}
        )
            .environment(AppDIContainer.shared.makeCatalogViewModel())
            .environment(CartPreviewData.makeCart())
            .previewThemes()
    }
}
