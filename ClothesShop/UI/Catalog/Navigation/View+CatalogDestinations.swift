import SwiftUI

extension View {
    func catalogDestinations(notificationsViewModel: NotificationsViewModel? = nil) -> some View {
        modifier(CatalogDestinations(notificationsViewModel: notificationsViewModel))
    }
}
