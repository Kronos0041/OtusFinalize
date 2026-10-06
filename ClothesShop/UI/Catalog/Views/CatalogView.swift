//
//  CatalogView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Вкладка «Товары»: шапка с колокольчиком и каталог.
struct CatalogView: View {
    @EnvironmentObject private var products: CatalogViewModel
    @StateObject private var notifications: NotificationsViewModel
    @State private var showNotification = false

    init(notificationsViewModel: NotificationsViewModel) {
        _notifications = StateObject(wrappedValue: notificationsViewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $showNotification) {
                    NotificationsView(backButton: $showNotification)
                        .environmentObject(notifications)
                } label: {
                    EmptyView()
                }

                VStack(spacing: 15) {
                    MainTopBar(notificationCount: notifications.unreadCount) {
                        showNotification.toggle()
                    }

                    SearchTextField(frame: (getWidth() - AppLayout.sideInset, 50),
                                    placeholder: SwiftGen.Common.search,
                                    text: $products.searchText)

                    ViewModeView(products.mode,
                                 emptyTitle: SwiftGen.Catalog.empty,
                                 retry: { products.reload() }) { _ in
                        CatalogSectionTabsView()
                            .environmentObject(products)
                    }
                }
                .frame(width: getWidth())
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            notifications.reload()
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView(notificationsViewModel: AppDIContainer.shared.makeNotificationsViewModel())
            .environmentObject(AppDIContainer.shared.makeCatalogViewModel())
            .previewThemes()
    }
}
