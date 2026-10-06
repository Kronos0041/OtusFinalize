import SwiftUI

/// Экраны стека вкладок «Главная» и «Избранное» для `CatalogRoute`.
struct CatalogDestinations: ViewModifier {
    /// ViewModel уведомлений; `nil` во вкладках, где колокольчика нет.
    let notifications: NotificationsViewModel?

    func body(content: Content) -> some View {
        content.navigationDestination(for: CatalogRoute.self) { route in
            switch route {
            case .notifications:
                if let notifications {
                    NotificationsView(notifications: notifications)
                }
            case .productDetails(let productID):
                ProductDetailsScreen(productID: productID)
            }
        }
    }
}
