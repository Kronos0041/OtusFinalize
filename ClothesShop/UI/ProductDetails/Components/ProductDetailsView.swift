import SwiftUI

struct ProductDetailsView: View {
    let product: CatalogItemUIModel
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
        RemoteImageView(url: product.imageURL, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .background(Color.appGray.opacity(0.08))
            .accessibilityLabel(Text(verbatim: product.title))
    }
}

#if DEBUG
struct ProductDetailsView_Previews: PreviewProvider {
    /// На экране view лежит внутри `List`; в превью нужен свой `ScrollView`, иначе длинный контент обрезается.
    private static func details(_ product: CatalogItemUIModel, size: String?) -> some View {
        ScrollView {
            ProductDetailsView(product: product, selectedSize: .constant(size), imageSize: 340)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    static var previews: some View {
        Group {
            details(PreviewData.cartItems[0].product, size: "M")
                .previewThemes("Размер выбран")
            details(PreviewData.cartItems[0].product, size: nil)
                .previewThemes("Размер не выбран")
            details(PreviewData.productWithoutSizes, size: nil)
                .previewThemes("Без размеров (sizes.isEmpty)")
            details(PreviewData.productWithoutImage, size: "M")
                .previewThemes("Без картинки")
            details(PreviewData.productLongContent, size: "XL")
                .previewThemes("Длинные тексты, много размеров")
        }
    }
}
#endif
