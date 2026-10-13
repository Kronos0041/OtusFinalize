//
//  CatalogView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Вкладка «Товары»: шапка с колокольчиком и каталог.
struct CatalogView: View {
    @Environment(CatalogViewModel.self) private var catalogViewModel
    /// Владеет ViewModel уведомлений `MainTabView`; здесь только наблюдение.
    let notificationsViewModel: NotificationsViewModel
    let openCart: () -> Void
    @State private var router = Router<CatalogRoute>()

    var body: some View {
        NavigationStack(path: Binding(get: { router.path }, set: router.updatePath)) {
            VStack(spacing: 15) {
                MainTopBar(
                    notificationCount: notificationsViewModel.unreadCount,
                    clickBell: { router.push(.notifications) },
                    clickCart: openCart
                )

                ViewModeView(
                    catalogViewModel.mode,
                    emptyTitle: SwiftGen.Catalog.empty,
                    retry: { catalogViewModel.reload() }
                ) { _ in
                    CatalogSectionTabsView()
                }
            }
            .frame(width: getWidth())
            .toolbar(.hidden, for: .navigationBar)
            .catalogDestinations(notificationsViewModel: notificationsViewModel)
        }
        .environment(router)
        .onAppear {
            notificationsViewModel.reload()
        }
    }
}

#if DEBUG
struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            content(AppDIContainer.mock(favoriteIDs: [PreviewData.watch.id]))
                .previewThemes("Каталог")
            content(AppDIContainer.mock(catalog: .loading))
                .previewThemes("Загрузка")
            content(AppDIContainer.mock(catalog: .success(PreviewData.emptyCatalog)))
                .previewThemes("Пусто")
            content(AppDIContainer.mock(isConnected: false))
                .previewThemes("Нет сети")
            content(AppDIContainer.mock(catalog: .failure(MockError("Сервер недоступен"))))
                .previewThemes("Ошибка")
        }
    }

    private static func content(_ container: AppDIContainer) -> some View {
        CatalogView(
            notificationsViewModel: container.makeNotificationsViewModel(),
            openCart: {}
        )
            .environment(container.makeLoadedCatalogViewModel())
            .environment(container.makeLoadedCartViewModel())
    }
}
#endif
