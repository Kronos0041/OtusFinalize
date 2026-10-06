//
//  NotificationsView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct NotificationsView: View {
    let notifications: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TopBarDescriptionView(title: SwiftGen.Notifications.title,
                                  onBack: { dismiss() },
                                  frame: (width: getWidth() - 20, height: 50))

            ViewModeView(notifications.mode,
                         emptyTitle: SwiftGen.Notifications.empty,
                         retry: { notifications.reload() }) { items in
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
        let viewModel = AppDIContainer.shared.makeNotificationsViewModel()
        viewModel.applyPreview(items: [
                Notification(id: "new-collection", remoteID: 1,
                                 title: "Новая коллекция", description: "Часы и аксессуары уже в каталоге."),
                Notification(id: "favorites", remoteID: 2,
                                 title: "Ваши избранные товары", description: "Сохранённые товары всегда под рукой.")
            ], readIDs: ["favorites"])
        return NotificationsView(notifications: viewModel)
            .previewThemes()
    }
}
#endif
