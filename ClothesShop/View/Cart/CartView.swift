import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartVM
    @EnvironmentObject private var products: MainGrideVM
    let continueShopping: () -> Void
    
    @State private var showCheckout = false
    @State private var showSuccess = false
    @State private var didCompleteCheckout = false

    private var items: [CartItem] { cart.resolvedItems(in: products.list.first?.product ?? []) }
    
    private var total: Int { items.reduce(0) { $0 + $1.product.price * $1.quantity } }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                ViewModeView(cart.viewMode,
                             emptyTitle: SwiftGen.Cart.empty,
                             emptySystemImage: "bag",
                             emptyMessage: SwiftGen.Cart.emptyHint) { _ in
                    CartItemsListView(items: items, total: total,
                                      changeQuantity: cart.changeQuantity,
                                      remove: cart.remove)
                }
                CartActionsView(isEmpty: items.isEmpty,
                                checkout: { showCheckout = true },
                                continueShopping: continueShopping)
            }
            .background(Color.appWhite)
            .foregroundColor(.appBlack)
            .navigationTitle(SwiftGen.Cart.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { products.loadIfNeeded() }
        .sheet(isPresented: $showCheckout, onDismiss: checkoutDismissed) {
            CartCheckoutView(items: items, total: total,
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
        cart.clear()
        didCompleteCheckout = true
        showCheckout = false
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
        CartView(continueShopping: {})
            .environmentObject(CartPreviewData.makeCart())
            .environmentObject(MainGrideVM(previewProducts: CartPreviewData.items.map(\.product)))
            .previewThemes()
    }
}
#endif
