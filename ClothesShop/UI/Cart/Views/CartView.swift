import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartViewModel
    @EnvironmentObject private var products: CatalogViewModel
    let continueShopping: () -> Void

    @State private var showCheckout = false
    @State private var showSuccess = false
    @State private var didCompleteCheckout = false

    private var items: [CartItemViewModel] {
        cart.resolvedItems(in: products.sections.first?.products ?? [])
    }

    private var total: Int { items.reduce(0) { $0 + $1.product.price * $1.quantity } }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                ViewModeView(cart.mode,
                             emptyTitle: SwiftGen.Cart.empty,
                             emptySystemImage: "bag",
                             emptyMessage: SwiftGen.Cart.emptyHint,
                             retry: reloadCart) { _ in
                    CartItemsListView(items: items, total: total,
                                      maximumQuantity: cart.maximumQuantity,
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
        cart.clear { success in
            guard success else { return }
            didCompleteCheckout = true
            showCheckout = false
        }
    }

    private func reloadCart() {
        if let catalog = products.sections.first?.products {
            cart.reload(catalog: catalog)
        } else {
            products.reload {
                cart.reload(catalog: products.sections.first?.products ?? [])
            }
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
        let catalog = AppDIContainer.shared.makeCatalogViewModel()
        catalog.applyPreview(products: CartPreviewData.items.map(\.product))
        return CartView(continueShopping: {})
            .environmentObject(CartPreviewData.makeCart())
            .environmentObject(catalog)
            .previewThemes()
    }
}
#endif
