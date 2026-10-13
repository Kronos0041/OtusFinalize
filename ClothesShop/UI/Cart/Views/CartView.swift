import SwiftUI

struct CartView: View {
    @Environment(CartViewModel.self) private var cartViewModel
    let continueShopping: () -> Void
    /// Повтор загрузки корзины (вместе с каталогом, если его ещё нет).
    let reload: () -> Void

    @State private var showCheckout = false
    @State private var showSuccess = false
    @State private var didCompleteCheckout = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ViewModeView(
                    cartViewModel.mode,
                    emptyTitle: SwiftGen.Cart.empty,
                    emptySystemImage: "bag",
                    emptyMessage: SwiftGen.Cart.emptyHint,
                    retry: reload
                ) { _ in
                    CartItemsListView(
                        items: cartViewModel.items,
                        total: cartViewModel.total,
                        maximumQuantity: cartViewModel.maximumQuantity,
                        changeQuantity: cartViewModel.changeQuantity,
                        remove: cartViewModel.remove
                    )
                }
                CartActionsView(
                    isEmpty: cartViewModel.items.isEmpty,
                    checkout: { showCheckout = true },
                    continueShopping: continueShopping
                )
            }
            .background(Color.appWhite)
            .foregroundColor(.appBlack)
            .navigationTitle(SwiftGen.Cart.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCheckout, onDismiss: checkoutDismissed) {
            CartCheckoutView(
                items: cartViewModel.items,
                total: cartViewModel.total,
                confirm: confirmCheckout,
                cancel: { showCheckout = false }
            )
        }
        .alert(SwiftGen.Cart.demoSuccess, isPresented: $showSuccess) {
            Button(SwiftGen.Common.ok, role: .cancel) {}
        } message: {
            Text(SwiftGen.Cart.demoHint)
        }
    }

    private func confirmCheckout() {
        Task {
            guard await cartViewModel.clear() else { return }
            didCompleteCheckout = true
            showCheckout = false
        }
    }

    private func checkoutDismissed() {
        if didCompleteCheckout {
            didCompleteCheckout = false
            showSuccess = true
        }
    }
}

#if DEBUG
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            content(AppDIContainer.mock())
                .previewThemes("С товарами")
            content(AppDIContainer.mock(cartItems: []))
                .previewThemes("Пустая")
            content(AppDIContainer.mock(settings: .loading))
                .previewThemes("Загрузка")
            content(AppDIContainer.mock(settings: .failure(MockError("Сервер недоступен"))))
                .previewThemes("Ошибка")
        }
    }

    private static func content(_ container: AppDIContainer) -> some View {
        CartView(continueShopping: {}, reload: {})
            .environment(container.makeLoadedCartViewModel())
    }
}
#endif
