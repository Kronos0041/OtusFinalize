import SwiftUI

struct CartCheckoutView: View {
    let items: [CartItem]
    let total: Int
    let confirm: () -> Void
    let cancel: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(verbatim: item.product.title)
                            if let size = item.size {
                                Text(SwiftGen.Cart.size(size)).foregroundColor(.appGray)
                            }
                            Text(SwiftGen.Cart.lineTotal(item.quantity,
                                PriceFormatter.string(from: item.product.price * item.quantity)))
                        }
                    }
                }
                Section {
                    HStack {
                        Text(SwiftGen.Cart.total).foregroundColor(.appBlack)
                        Spacer()
                        Text(verbatim: PriceFormatter.string(from: total))
                            .font(.body.weight(.bold))
                    }
                } footer: {
                    Text(SwiftGen.Cart.demoHint)
                }
                Section {
                    Button(SwiftGen.Cart.confirmDemo, action: confirm)
                        .disabled(items.isEmpty)
                }
            }
            .navigationTitle(SwiftGen.Cart.checkout)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(SwiftGen.Common.cancel, action: cancel)
                }
            }
            .tint(.appBlack)
        }
    }
}

#if DEBUG
struct CartCheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CartCheckoutView(items: CartPreviewData.items, total: CartPreviewData.total,
                         confirm: {}, cancel: {})
            .previewThemes()
    }
}
#endif
