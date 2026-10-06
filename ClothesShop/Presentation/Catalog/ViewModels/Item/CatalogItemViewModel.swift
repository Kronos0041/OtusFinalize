import Foundation

struct CatalogItemViewModel: Identifiable, Equatable, Codable {
    let id: String
    let categoryID: String
    let imageURL: URL?
    let title: String
    let shortDescription: String
    let description: String
    let price: Int
    let sizes: [String]

    var formattedPrice: String { PriceFormatter.string(from: price) }

    init(product: Product) {
        id = product.id
        categoryID = product.categoryID
        imageURL = product.imageURL
        title = product.title
        shortDescription = product.shortDescription
        description = product.description
        price = product.price
        sizes = product.sizes
    }

    init(id: String, categoryID: String, imageURL: URL?, title: String,
         shortDescription: String, description: String, price: Int, sizes: [String]) {
        self.id = id; self.categoryID = categoryID; self.imageURL = imageURL
        self.title = title; self.shortDescription = shortDescription
        self.description = description; self.price = price; self.sizes = sizes
    }
}
