//
//  NotificationsView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct NotificationsView: View {
    let notifications: NotificationsViewModel
    @Environment(Router<CatalogRoute>.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            TopBarDescriptionView(
                title: SwiftGen.Notifications.title,
                onBack: { router.pop() },
                frame: (width: getWidth() - 20, height: 50)
            )

            ViewModeView(
                notifications.mode,
                emptyTitle: SwiftGen.Notifications.empty,
                retry: { notifications.reload() }
            ) { items in
                List(items) { item in
                    Button {
                        notifications.markRead(item)
                    } label: {
                        NotificationRowView(item: item, isUnread: notifications.isUnread(item))
                    }
                    .buttonStyle(.plain)
                }
                .refreshable { await notifications.refresh() }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { notifications.reload() }
    }
}

#if DEBUG
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationsView(notifications: AppDIContainer.mock(readNotificationIDs: ["favorites"])
                .makeNotificationsViewModel())
                .environment(Router<CatalogRoute>())
                .previewThemes("Список")
            NotificationsView(notifications: AppDIContainer.mock(notifications: .success([]))
                .makeNotificationsViewModel())
                .environment(Router<CatalogRoute>())
                .previewThemes("Пусто")
            NotificationsView(notifications: AppDIContainer.mock(isConnected: false)
                .makeNotificationsViewModel())
                .environment(Router<CatalogRoute>())
                .previewThemes("Нет сети")
        }
    }
}
#endif
