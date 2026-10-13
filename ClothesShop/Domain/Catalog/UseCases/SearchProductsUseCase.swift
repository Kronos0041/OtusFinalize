import Foundation

struct SearchProductsUseCase {
    func searchProducts(in products: [Product], query: String) -> [Product] {
        let terms = query.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !terms.isEmpty else { return products }
        return products.filter { product in
            let text = [product.title, product.shortDescription, product.description]
                .joined(separator: " ")
            return terms.allSatisfy { text.localizedStandardContains($0) }
        }
    }
}
