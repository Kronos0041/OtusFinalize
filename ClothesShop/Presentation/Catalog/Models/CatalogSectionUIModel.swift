struct CatalogSectionUIModel: Identifiable {
    let id: String
    let category: CategoryUIModel
    var products: [CatalogItemUIModel]

    static let allCategory = CategoryUIModel(id: "all", title: SwiftGen.Catalog.all)

    static func sections(from catalog: Catalog) -> [CatalogSectionUIModel] {
        let products = catalog.products.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        let sections = catalog.categories.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
            .compactMap { category -> CatalogSectionUIModel? in
                let items = products.filter { $0.categoryID == category.id }.map(CatalogItemUIModel.init)
                guard !items.isEmpty else { return nil }
                return CatalogSectionUIModel(
                    id: category.id,
                    category: .init(id: category.id, title: category.title),
                    products: items
                )
            }
        let allProducts = CatalogSectionUIModel(
            id: allCategory.id,
            category: allCategory,
            products: sections.flatMap(\.products)
        )
        return [allProducts] + sections
    }
}
