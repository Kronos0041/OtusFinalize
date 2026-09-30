//
//  NotificationView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var notifications: NotificationsVM
    @Binding var backButton: Bool

    var body: some View {
        VStack(spacing: 0) {
            TopBarDescriptionView(title: "Уведомления",
                                  backButton: $backButton,
                                  frame: (width: getWidth() - 20, height: 50))

            ViewModeView(notifications.viewMode,
                         emptyTitle: "Уведомлений пока нет",
                         retry: { notifications.reload() }) { items in
                List(items) { item in
                    Button {
                        notifications.markRead(item)
                    } label: {
                        NotificationRow(item: item, isUnread: notifications.isUnread(item))
                    }
                    .buttonStyle(.plain)
                }
                .refreshable { await notifications.refresh() }
            }
        }
        .navigationBarHidden(true)
        .onAppear { notifications.reload() }
    }
}

/// Строка уведомления. Непрочитанное — с синей точкой и жирным заголовком.
private struct NotificationRow: View {
    let item: NotificationItem
    let isUnread: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(isUnread ? Color.blue : Color.clear)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: item.title)
                    .fontWeight(isUnread ? .bold : .regular)
                if !item.description.isEmpty {
                    Text(verbatim: item.description)
                        .font(.subheadline)
                        .foregroundColor(.appGray)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(isUnread ? Text("Нажмите, чтобы отметить прочитанным") : Text(verbatim: ""))
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(backButton: .constant(false))
            .environmentObject(NotificationsVM())
    }
}
