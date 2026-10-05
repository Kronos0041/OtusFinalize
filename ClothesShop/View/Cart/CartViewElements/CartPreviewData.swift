#if DEBUG
import Foundation

enum CartPreviewData {
    static let items = [
        CartItem(id: UUID(),
                 product: MainGrideDateModel(id: "watch-moonphase-rose", categoryId: "watches",
                                            imageURL: URL(string: "https://test-6d334.web.app/products/watch-moonphase-rose.png?v=c762e51f76c9"),
                                            title: "Moonphase Rose", shortDescription: "Розовое золото, фаза луны",
                                            description: "Часы с индикатором фазы луны.", price: 245000, sizes: ["S", "M", "L"]),
                 size: "M", quantity: 1),
        CartItem(id: UUID(),
                 product: MainGrideDateModel(id: "preview-glasses", categoryId: "accessories",
                                            imageURL: URL(string: "https://test-6d334.web.app/products/glasses-navigator.png?v=48d43a195b88"),
                                            title: "Navigator Sunglasses", shortDescription: "",
                                            description: "", price: 24900, sizes: []),
                 size: nil, quantity: 2)
    ]

    static var total: Int {
        items.reduce(0) { $0 + $1.product.price * $1.quantity }
    }

    static func makeCart(isEmpty: Bool = false) -> CartVM {
        let cart = CartVM(ownerID: nil)
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
