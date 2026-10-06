import SwiftUI

extension View {
    func catalogDestinations(notifications: NotificationsViewModel? = nil) -> some View {
        modifier(CatalogDestinations(notifications: notifications))
    }
}
