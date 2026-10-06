import SwiftUI

struct CartView: View {
    @Environment(CartViewModel.self) private var cart
    let continueShopping: () -> Void
    /// Повтор загрузки корзины (вместе с каталогом, если его ещё нет).
    let reload: () -> Void

    @State private var showCheckout = false
    @State private var showSuccess = false
    @State private var didCompleteCheckout = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ViewModeView(cart.mode,
                             emptyTitle: SwiftGen.Cart.empty,
                             emptySystemImage: "bag",
                             emptyMessage: SwiftGen.Cart.emptyHint,
                             retry: reload) { _ in
                    CartItemsListView(items: cart.items, total: cart.total,
                                      maximumQuantity: cart.maximumQuantity,
                                      changeQuantity: cart.changeQuantity,
                                      remove: cart.remove)
                }
                CartActionsView(isEmpty: cart.items.isEmpty,
                                checkout: { showCheckout = true },
                                continueShopping: continueShopping)
            }
            .background(Color.appWhite)
            .foregroundColor(.appBlack)
            .navigationTitle(SwiftGen.Cart.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCheckout, onDismiss: checkoutDismissed) {
            CartCheckoutView(items: cart.items, total: cart.total,
                             confirm: confirmCheckout,
                             cancel: { showCheckout = false })
        }
        .alert(SwiftGen.Cart.demoSuccess, isPresented: $showSuccess) {
            Button(SwiftGen.Common.ok, role: .cancel) {}
        } message: {
            Text(SwiftGen.Cart.demoHint)
        }
    }

    private func confirmCheckout() {
        Task {
            guard await cart.clear() else { return }
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
        CartView(continueShopping: {}, reload: {})
            .environment(CartPreviewData.makeCart())
            .previewThemes()
    }
}
#endif
