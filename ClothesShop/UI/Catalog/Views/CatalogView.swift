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
        NavigationStack(path: Binding(get: { router.path }, set: router.updatePath)) {
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

#if DEBUG
struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            content(AppDIContainer.preview(favoriteIDs: [PreviewData.watch.id]))
                .previewThemes("Каталог")
            content(AppDIContainer.preview(catalog: .loading))
                .previewThemes("Загрузка")
            content(AppDIContainer.preview(catalog: .success(PreviewData.emptyCatalog)))
                .previewThemes("Пусто")
            content(AppDIContainer.preview(isConnected: false))
                .previewThemes("Нет сети")
            content(AppDIContainer.preview(catalog: .failure(PreviewError("Сервер недоступен"))))
                .previewThemes("Ошибка")
        }
    }

    private static func content(_ container: AppDIContainer) -> some View {
        CatalogView(
            notifications: container.makeNotificationsViewModel(),
            openCart: {}
        )
            .environment(container.makeLoadedCatalogViewModel())
            .environment(container.makeLoadedCartViewModel())
    }
}
#endif
