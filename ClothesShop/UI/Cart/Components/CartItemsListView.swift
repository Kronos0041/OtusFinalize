import SwiftUI

struct CartItemsListView: View {
    let items: [CartItemUIModel]
    let total: Int
    let maximumQuantity: Int
    let changeQuantity: (String, Int) -> Void
    let remove: (String) -> Void

    var body: some View {
        List {
            ForEach(items) { item in
                CartSwipeDeleteRow(remove: { remove(item.id) }) {
                    CartRowView(
                        item: item,
                        maximumQuantity: maximumQuantity,
                        decrease: {
                            if item.quantity == 1 {
                                withAnimation { changeQuantity(item.id, -1) }
                            } else {
                                changeQuantity(item.id, -1)
                            }
                        },
                        increase: { changeQuantity(item.id, 1) }
                    )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.appWhite)
            }
            HStack {
                Text(SwiftGen.Cart.total).foregroundColor(.appGray)
                Spacer()
                Text(verbatim: PriceFormatter.string(from: total))
                    .font(.system(size: 23, weight: .semibold))
            }
                .padding(.vertical, 16)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.appWhite)
        }
        .listStyle(.plain)
    }
}

#if DEBUG
struct CartItemsListView_Previews: PreviewProvider {
    static var previews: some View {
        CartItemsListView(
            items: PreviewData.cartItems,
            total: PreviewData.cartTotal,
            maximumQuantity: StoreSettings.default.maximumCartItemQuantity,
            changeQuantity: { _, _ in },
            remove: { _ in }
        )
            .background(Color.appWhite)
            .previewThemes()
    }
}
#endif
