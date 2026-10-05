import SwiftUI

struct ProductDetailsView: View {
    let product: MainGrideDateModel
    @Binding var selectedSize: String?
    let imageSize: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            productImage
                .frame(height: imageSize)
                .clipped()

            VStack(alignment: .leading, spacing: 24) {
                productSummary

                if !product.sizes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(SwiftGen.Product.size)
                            .font(.system(size: 16, weight: .medium))
                        SizeCollection(sizes: product.sizes, selection: $selectedSize)
                        if selectedSize == nil {
                            Text(SwiftGen.Cart.chooseSize)
                                .font(.footnote)
                                .foregroundColor(.appGray)
                        }
                    }
                }

                Divider()

                Text(verbatim: product.description)
                    .font(.system(size: 16))
                    .foregroundColor(.appGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var productSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: product.title)
                .font(.system(size: 22, weight: .medium, design: .serif))
                .fixedSize(horizontal: false, vertical: true)

            Text(verbatim: product.shortDescription)
                .font(.system(size: 16))
                .foregroundColor(.appGray)
                .fixedSize(horizontal: false, vertical: true)

            Text(verbatim: product.formattedPrice)
                .font(.system(size: 18, weight: .semibold))
                .padding(.top, 8)
                .accessibilityLabel(Text(SwiftGen.Product.price) + Text(" ") + Text(verbatim: product.formattedPrice))
        }
    }

    private var productImage: some View {
        AsyncImage(url: product.imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFit()
            case .empty where product.imageURL != nil:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                Image(systemName: "photo")
                    .font(.system(size: 36))
                    .foregroundColor(.appGray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appGray.opacity(0.08))
        .accessibilityLabel(Text(verbatim: product.title))
    }
}

#if DEBUG
struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(product: CartPreviewData.items[0].product,
                           selectedSize: .constant("M"), imageSize: 340)
            .previewThemes()
    }
}
#endif
