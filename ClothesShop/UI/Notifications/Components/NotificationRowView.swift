import SwiftUI

/// Строка уведомления. Непрочитанное — с синей точкой и жирным заголовком.
struct NotificationRowView: View {
    let item: Notification
    let isUnread: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(isUnread ? Color.blue : Color.clear)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: item.title).fontWeight(isUnread ? .bold : .regular)
                if !item.description.isEmpty {
                    Text(verbatim: item.description).font(.subheadline).foregroundColor(.appGray)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(isUnread ? Text(SwiftGen.Notifications.markRead) : Text(verbatim: ""))
    }
}
