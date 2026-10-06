struct CatalogSectionViewModel: Identifiable {
    let id: String
    let category: CategoryItemViewModel
    var products: [CatalogItemViewModel]

    static let allCategory = CategoryItemViewModel(id: "all", title: SwiftGen.Catalog.all)

    static func sections(from catalog: Catalog) -> [CatalogSectionViewModel] {
        let products = catalog.products.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        let sections = catalog.categories.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
            .compactMap { category -> CatalogSectionViewModel? in
                let items = products.filter { $0.categoryID == category.id }.map(CatalogItemViewModel.init)
                guard !items.isEmpty else { return nil }
                return CatalogSectionViewModel(
                    id: category.id,
                    category: .init(id: category.id, title: category.title),
                    products: items
                )
            }
        let allProducts = CatalogSectionViewModel(
            id: allCategory.id,
            category: allCategory,
            products: sections.flatMap(\.products)
        )
        return [allProducts] + sections
    }
}
