//
//  MainView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Вкладка «Товары»: шапка с колокольчиком и каталог.
struct MainView: View {
    @StateObject private var products = MainGrideVM()
    @StateObject private var notifications = NotificationsVM()
    @State private var showNotification = false

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $showNotification) {
                    NotificationView(backButton: $showNotification)
                        .environmentObject(notifications)
                } label: {
                    EmptyView()
                }

                VStack(spacing: 15) {
                    MainTopBar(notificationCount: notifications.unreadCount) {
                        showNotification.toggle()
                    }

                    ViewModeView(products.viewMode,
                                 emptyTitle: "Каталог пока пуст",
                                 retry: { products.reload() }) { _ in
                        MainTabView()
                            .environmentObject(products)
                    }
                }
                .frame(width: getWidth())
            }
        }
        .onAppear {
            products.loadIfNeeded()
            notifications.reload()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
