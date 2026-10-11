//
//  CategoryCollectionTab.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Листаемые страницы каталога — по одной на категорию.
struct CategoryCollectionTab: View {
    @Environment(CatalogViewModel.self) private var products

    var body: some View {
        let sections = products.filteredSections
        TabView(selection: Binding(
            get: { products.selectedCategoryIndex },
            set: { products.selectCategory(at: $0) }
        )) {
            ForEach(sections.indices, id: \.self) { index in
                CatalogGridView(
                    section: sections[index],
                    emptyTitle: products.isSearching ? SwiftGen.Catalog.Search.empty : nil,
                    emptySystemImage: "magnifyingglass",
                    emptyMessage: SwiftGen.Catalog.Search.changeQuery,
                    header: CatalogHeaderView()
                )
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
    }
}

#if DEBUG
struct CategoryCollectionTab_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionTab()
            .environment(AppDIContainer.preview().makeLoadedCatalogViewModel())
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }
}
#endif
