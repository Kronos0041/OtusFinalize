import Foundation

struct ProductDTO: Decodable {
    let id: String
    let categoryId: String
    let title: String
    let imageURL: URL?
    let shortDescription: String
    let description: String
    let price: Int
    let sizes: [String]?
    let badge: String?
    let order: Int?
}
