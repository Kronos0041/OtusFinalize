import SwiftUI

/// Экраны стека вкладок «Главная» и «Избранное» для `CatalogRoute`.
struct CatalogDestinations: ViewModifier {
    /// ViewModel уведомлений; `nil` во вкладках, где колокольчика нет.
    let notificationsViewModel: NotificationsViewModel?

    func body(content: Content) -> some View {
        content.navigationDestination(for: CatalogRoute.self) { route in
            switch route {
            case .notifications:
                if let notificationsViewModel {
                    NotificationsView(notificationsViewModel: notificationsViewModel)
                }
            case .productDetails(let productID):
                ProductDetailsScreen(productID: productID)
            }
        }
    }
}
