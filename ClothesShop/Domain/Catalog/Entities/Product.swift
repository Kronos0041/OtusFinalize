import Foundation

struct Product: Identifiable, Equatable, Codable {
    let id: String
    let categoryID: String
    let imageURL: URL?
    let title: String
    let shortDescription: String
    let description: String
    let price: Int
    let sizes: [String]
    let badge: String?
    let order: Int?
}
