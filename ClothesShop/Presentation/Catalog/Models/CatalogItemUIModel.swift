import Foundation

struct CatalogItemUIModel: Identifiable, Equatable, Codable {
    let id: String
    let categoryID: String
    let imageURL: URL?
    let title: String
    let shortDescription: String
    let description: String
    let price: Int
    let sizes: [String]
    let badge: String?

    var formattedPrice: String { PriceFormatter.string(from: price) }

    /// Текст для «Поделиться»: название, цена, краткое описание и ссылка на фото.
    var shareText: String {
        [title, formattedPrice, shortDescription, imageURL?.absoluteString]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    init(product: Product) {
        id = product.id
        categoryID = product.categoryID
        imageURL = product.imageURL
        title = product.title
        shortDescription = product.shortDescription
        description = product.description
        price = product.price
        sizes = product.sizes
        badge = product.badge
    }

    init(id: String, categoryID: String, imageURL: URL?, title: String,
         shortDescription: String, description: String, price: Int, sizes: [String],
         badge: String? = nil) {
        self.id = id; self.categoryID = categoryID; self.imageURL = imageURL
        self.title = title; self.shortDescription = shortDescription
        self.description = description; self.price = price; self.sizes = sizes
        self.badge = badge
    }
}
