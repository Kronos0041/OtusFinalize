import SwiftUI

struct CartRowView: View {
    let item: CartItemViewModel
    let maximumQuantity: Int
    let decrease: () -> Void
    let increase: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RemoteImageView(url: item.product.imageURL, contentMode: .fit, placeholderIconSize: 20)
                .frame(width: 80, height: 96)
                .background(Color.appGray.opacity(0.08))
                .clipped()
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: item.product.title)
                    .font(.system(size: 16, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: item.product.formattedPrice)
                    .font(.system(size: 16))
                HStack(alignment: .bottom, spacing: 8) {
                    if let size = item.size {
                        Text(SwiftGen.Cart.size(size))
                            .font(.system(size: 13))
                            .foregroundColor(.appGray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    quantityControl
                }
                .padding(.top, 8)
            }
        }
        .foregroundColor(.appBlack)
    }

    private var quantityControl: some View {
        HStack(spacing: 4) {
            quantityButton("minus",
                           label: item.quantity == 1 ? SwiftGen.Cart.delete : SwiftGen.Cart.decrease,
                           disabled: false,
                           action: decrease)
            Text(verbatim: "\(item.quantity)")
                .font(.system(size: 16, weight: .semibold))
                .monospacedDigit()
                .frame(width: 26)
            quantityButton("plus", label: SwiftGen.Cart.increase,
                           disabled: item.quantity >= maximumQuantity, action: increase)
        }
    }

    private func quantityButton(_ icon: String, label: String, disabled: Bool,
                                action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 32, height: 32)
                .background(Circle().stroke(Color.appGray.opacity(0.25), lineWidth: 1))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(Text(label))
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1)
    }
}

#if DEBUG
struct CartRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CartRowView(item: CartPreviewData.items[0],
                        maximumQuantity: StoreSettings.preview.maximumCartItemQuantity,
                        decrease: {}, increase: {})
                .previewDisplayName("With size")
            CartRowView(item: CartPreviewData.items[1],
                        maximumQuantity: StoreSettings.preview.maximumCartItemQuantity,
                        decrease: {}, increase: {})
                .previewDisplayName("Without size")
        }
        .padding(20)
        .background(Color.appWhite)
        .previewLayout(.sizeThatFits)
        .previewThemes()
    }
}
#endif
