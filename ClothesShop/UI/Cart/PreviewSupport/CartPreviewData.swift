#if DEBUG
import Foundation

@MainActor
enum CartPreviewData {
    static let items = [
        CartItemViewModel(
            id: "preview-watch-m",
            product: CatalogItemViewModel(
                id: "watch-moonphase-rose",
                categoryID: "watches",
                imageURL: URL(
                    string: "https://test-6d334.web.app/products/watch-moonphase-rose.png?v=c762e51f76c9"
                ),
                title: "Moonphase Rose",
                shortDescription: "Розовое золото, фаза луны",
                description: "Часы с индикатором фазы луны.",
                price: 245_000,
                sizes: ["S", "M", "L"],
                badge: "Новинка"
            ),
            size: "M",
            quantity: 1
        ),
        CartItemViewModel(
            id: "preview-glasses",
            product: CatalogItemViewModel(
                id: "preview-glasses",
                categoryID: "accessories",
                imageURL: URL(
                    string: "https://test-6d334.web.app/products/glasses-navigator.png?v=48d43a195b88"
                ),
                title: "Navigator Sunglasses",
                shortDescription: "",
                description: "",
                price: 24_900,
                sizes: []
            ),
            size: nil,
            quantity: 2
        )
    ]

    /// Товар без размеров (`sizes.isEmpty`): секция выбора размера скрыта, добавление в корзину доступно сразу.
    static var productWithoutSizes: CatalogItemViewModel { items[1].product }

    /// Крайний случай по тексту и размерам: длинные строки, много размеров, большая цена.
    static let productLongContent = CatalogItemViewModel(
        id: "preview-long",
        categoryID: "watches",
        imageURL: nil,
        title: "Часы Moonphase Rose Limited Edition с ремешком из итальянской телячьей кожи",
        shortDescription: "Розовое золото, фаза луны, сапфировое стекло, автоподзавод, запас хода 80 часов",
        description: String(repeating: "Часы с индикатором фазы луны и сапфировым стеклом. ", count: 12),
        price: 12_450_000,
        sizes: ["XS", "S", "M", "L", "XL", "XXL", "3XL", "4XL"])

    /// Товар без картинки: показывается заглушка `RemoteImageView`.
    static var productWithoutImage: CatalogItemViewModel {
        let product = items[0].product
        return CatalogItemViewModel(
            id: product.id,
            categoryID: product.categoryID,
            imageURL: nil,
            title: product.title,
            shortDescription: product.shortDescription,
            description: product.description,
            price: product.price,
            sizes: product.sizes,
            badge: product.badge
        )
    }

    static var total: Int {
        items.reduce(0) { $0 + $1.product.price * $1.quantity }
    }

    static func makeCart(isEmpty: Bool = false) -> CartViewModel {
        let cart = AppDIContainer.shared.makeCartViewModel(ownerID: nil)
        if !isEmpty {
            for item in items {
                for _ in 0..<item.quantity {
                    cart.add(item.product, size: item.size)
                }
            }
        }
        return cart
    }
}
#endif
