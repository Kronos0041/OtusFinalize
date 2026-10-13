//
//  NotificationsView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct NotificationsView: View {
    let notificationsViewModel: NotificationsViewModel
    @Environment(Router<CatalogRoute>.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            TopBarDescriptionView(
                title: SwiftGen.Notifications.title,
                onBack: { router.pop() },
                frame: (width: getWidth() - 20, height: 50)
            )

            ViewModeView(
                notificationsViewModel.mode,
                emptyTitle: SwiftGen.Notifications.empty,
                retry: { notificationsViewModel.reload() }
            ) { items in
                List(items) { item in
                    Button {
                        notificationsViewModel.markRead(item)
                    } label: {
                        NotificationRowView(item: item, isUnread: notificationsViewModel.isUnread(item))
                    }
                    .buttonStyle(.plain)
                }
                .refreshable { await notificationsViewModel.refresh() }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { notificationsViewModel.reload() }
    }
}

#if DEBUG
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationsView(notificationsViewModel: AppDIContainer.mock(readNotificationIDs: ["favorites"])
                .makeNotificationsViewModel())
                .environment(Router<CatalogRoute>())
                .previewThemes("Список")
            NotificationsView(notificationsViewModel: AppDIContainer.mock(notifications: .success([]))
                .makeNotificationsViewModel())
                .environment(Router<CatalogRoute>())
                .previewThemes("Пусто")
            NotificationsView(notificationsViewModel: AppDIContainer.mock(isConnected: false)
                .makeNotificationsViewModel())
                .environment(Router<CatalogRoute>())
                .previewThemes("Нет сети")
        }
    }
}
#endif
