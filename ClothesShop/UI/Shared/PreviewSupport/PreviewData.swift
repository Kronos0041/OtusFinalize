#if DEBUG
import Foundation

/// Тестовые данные для SwiftUI Preview.
///
/// Domain-сущности (`catalog`, `cartRecords`, `notifications`, `profile`) отдаются mock-репозиториям
/// через `AppDIContainer.mock(...)`. Готовые элементы (`catalogItems`, `cartItems`, `product…`) —
/// для превью компонентов, которые принимают данные напрямую, без ViewModel.
enum PreviewData {
    static let ownerID = "preview-user"
    static let profile = UserProfile(email: "alex@example.com")

    // MARK: - Каталог

    static let watch = product(
        id: "watch-moonphase-rose", categoryID: "watches",
        image: "watch-moonphase-rose.png?v=c762e51f76c9",
        title: "Moonphase Rose", details: "Розовое золото, фаза луны",
        description: "Часы с индикатором фазы луны.",
        price: 245_000, sizes: ["S", "M", "L"], badge: "Новинка", order: 1
    )

    /// Товар без размеров (`sizes.isEmpty`): секция выбора размера скрыта, добавление в корзину доступно сразу.
    static let glasses = product(
        id: "glasses-navigator", categoryID: "glasses",
        image: "glasses-navigator.png?v=48d43a195b88",
        title: "Авиаторы Navigator", details: "Графитовые линзы, двойной мост",
        price: 32_900, order: 4
    )

    static let products: [Product] = [
        watch,
        product(
            id: "pen-classic-black", categoryID: "pens",
            image: "pen-classic-black.png?v=9d0c4d363d09",
            title: "Перьевая ручка Classic Black", details: "Чёрная смола, золотое перо",
            price: 79_000, badge: "Персонализация", order: 2
        ),
        product(
            id: "luggage-cabin-black", categoryID: "luggage",
            image: "luggage-cabin-black.png?v=104396fbe5cd",
            title: "Чемодан-кабина Black", details: "Ручная кладь, поликарбонат",
            price: 89_000, order: 3
        ),
        glasses,
        product(
            id: "watch-bronze-green", categoryID: "watches",
            image: "watch-bronze-green.png?v=aaded53fadfd",
            title: "Хронограф Bronze Green", details: "Бронзовый корпус, зелёный ремешок",
            price: 198_000, order: 5
        ),
        product(
            id: "pen-blue-resin", categoryID: "pens",
            image: "pen-blue-resin.png?v=9ef55a827b55",
            title: "Перьевая ручка Blue Resin", details: "Синий корпус, серебристый колпачок",
            price: 54_000, order: 6
        ),
        product(
            id: "glasses-panto-rose", categoryID: "glasses",
            image: "glasses-panto-rose.png?v=86197f3ff8d1",
            title: "Панто Rose", details: "Светлая оправа, голубые линзы",
            price: 28_500, order: 7
        ),
        product(
            id: "luggage-medium-black", categoryID: "luggage",
            image: "luggage-medium-black.png?v=83f17879befd",
            title: "Чемодан Medium Black", details: "Средний размер для поездки на неделю",
            price: 99_000, order: 8
        )
    ]

    static let categories = [
        Category(id: "watches", title: "Часы", order: 1),
        Category(id: "pens", title: "Ручки", order: 2),
        Category(id: "glasses", title: "Очки", order: 3),
        Category(id: "luggage", title: "Чемоданы", order: 4)
    ]

    static let catalog = Catalog(categories: categories, products: products)
    static let emptyCatalog = Catalog(categories: [], products: [])

    /// Каталог с заданными категориями, по одному товару в каждой: для превью ленты категорий.
    static func catalog(categoryTitles: [String]) -> Catalog {
        let categories = categoryTitles.enumerated().map { index, title in
            Category(id: "category-\(index)", title: title, order: index)
        }
        let products = categories.map { category in
            product(
                id: "product-\(category.id)", categoryID: category.id, image: nil,
                title: category.title, details: "", price: 1_000, order: category.order
            )
        }
        return Catalog(categories: categories, products: products)
    }

    static var catalogItems: [CatalogItemUIModel] { products.map(CatalogItemUIModel.init) }

    static var productWithoutSizes: CatalogItemUIModel { CatalogItemUIModel(product: glasses) }

    /// Крайний случай по тексту и размерам: длинные строки, много размеров, большая цена.
    static let longContent = product(
        id: "preview-long", categoryID: "watches", image: nil,
        title: "Часы Moonphase Rose Limited Edition с ремешком из итальянской телячьей кожи",
        details: "Розовое золото, фаза луны, сапфировое стекло, автоподзавод, запас хода 80 часов",
        description: String(repeating: "Часы с индикатором фазы луны и сапфировым стеклом. ", count: 12),
        price: 12_450_000, sizes: ["XS", "S", "M", "L", "XL", "XXL", "3XL", "4XL"]
    )

    static var productLongContent: CatalogItemUIModel { CatalogItemUIModel(product: longContent) }

    /// Товар без картинки: показывается заглушка `RemoteImageView`.
    static var productWithoutImage: CatalogItemUIModel {
        CatalogItemUIModel(product: product(
            id: watch.id, categoryID: watch.categoryID, image: nil,
            title: watch.title, details: watch.shortDescription, description: watch.description,
            price: watch.price, sizes: watch.sizes, badge: watch.badge
        ))
    }

    // MARK: - Корзина

    static let cartRecords = [
        CartItem(id: "preview-watch-m", productID: watch.id, size: "M", quantity: 1),
        CartItem(id: "preview-glasses", productID: glasses.id, size: nil, quantity: 2)
    ]

    static var cartItems: [CartItemUIModel] {
        cartRecords.compactMap { record in
            products.first { $0.id == record.productID }.map {
                CartItemUIModel(
                    id: record.id,
                    product: CatalogItemUIModel(product: $0),
                    size: record.size,
                    quantity: record.quantity
                )
            }
        }
    }

    static var cartTotal: Int {
        cartItems.reduce(0) { $0 + $1.product.price * $1.quantity }
    }

    // MARK: - Уведомления

    static let notifications = [
        Notification(
            id: "new-collection",
            remoteID: 1,
            title: "Новая коллекция",
            description: "Часы и аксессуары уже в каталоге."
        ),
        Notification(
            id: "favorites",
            remoteID: 2,
            title: "Ваши избранные товары",
            description: "Сохранённые товары всегда под рукой."
        )
    ]

    // MARK: - Вспомогательное

    private static func product(
        id: String,
        categoryID: String,
        image: String?,
        title: String,
        details: String,
        description: String? = nil,
        price: Int,
        sizes: [String] = [],
        badge: String? = nil,
        order: Int? = nil
    ) -> Product {
        Product(
            id: id,
            categoryID: categoryID,
            imageURL: image.flatMap { URL(string: "https://test-6d334.web.app/products/\($0)") },
            title: title,
            shortDescription: details,
            description: description ?? details,
            price: price,
            sizes: sizes,
            badge: badge,
            order: order
        )
    }
}
#endif
