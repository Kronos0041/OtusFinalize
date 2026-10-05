//
//  MainGrideModels.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

// MARK: - DTO
// Документы Firestore из коллекций `categories` и `products`.

struct CatalogDTO: Decodable {
    var categories: [CategoryDTO]
    var products: [ProductDTO]
}

struct CategoryDTO: Decodable {
    let id: String
    let title: String
    let order: Int?
}

struct ProductDTO: Decodable {
    let id: String
    let categoryId: String
    let title: String
    let imageURL: URL?
    let shortDescription: String
    let description: String
    /// Цена в рублях.
    let price: Int
    let sizes: [String]?
    let order: Int?
}

// MARK: - Модели экрана

/// Товар. Фото загружается по HTTPS URL из Firestore.
struct MainGrideDateModel: Identifiable, Equatable, Codable {
    let id: String
    let categoryId: String
    var imageURL: URL?
    var title: String
    var shortDescription: String
    var description: String
    var price: Int
    var sizes: [String]

    var formattedPrice: String { PriceFormatter.string(from: price) }
}

extension MainGrideDateModel {
    init(dto: ProductDTO) {
        id = dto.id
        categoryId = dto.categoryId
        imageURL = dto.imageURL
        title = dto.title
        shortDescription = dto.shortDescription
        description = dto.description
        price = dto.price
        sizes = dto.sizes ?? []
    }
}

/// Раздел каталога: категория + её товары.
struct ShopItemModel: Identifiable {
    let id: String
    var categoryName: CategoryCollectionButtonModel
    var product: [MainGrideDateModel]
}

extension ShopItemModel {
    func filtered(by query: String) -> ShopItemModel {
        let terms = query.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !terms.isEmpty else { return self }
        var section = self
        section.product = product.filter { item in
            let text = [item.title, item.shortDescription, item.description].joined(separator: " ")
            return terms.allSatisfy { text.localizedStandardContains($0) }
        }
        return section
    }

    static let allCategory = CategoryCollectionButtonModel(id: "all", title: SwiftGen.Catalog.all)

    /// Раздел «Все» + категории по `order`. Категории без товаров не показываются.
    static func sections(from catalog: CatalogDTO) -> [ShopItemModel] {
        let products = catalog.products
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
            .map(MainGrideDateModel.init(dto:))

        let sections: [ShopItemModel] = catalog.categories
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
            .compactMap { category -> ShopItemModel? in
                let items = products.filter { $0.categoryId == category.id }
                guard !items.isEmpty else { return nil }
                return ShopItemModel(id: category.id,
                                     categoryName: CategoryCollectionButtonModel(id: category.id, title: category.title),
                                     product: items)
            }

        let all = ShopItemModel(id: allCategory.id,
                                categoryName: allCategory,
                                product: sections.flatMap(\.product))
        return [all] + sections
    }
}

// MARK: - Форматирование

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "\u{00A0}"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// 24900 → «24 900 ₽»
    static func string(from rubles: Int) -> String {
        let number = formatter.string(from: NSNumber(value: rubles)) ?? "\(rubles)"
        return "\(number)\u{00A0}₽"
    }
}
