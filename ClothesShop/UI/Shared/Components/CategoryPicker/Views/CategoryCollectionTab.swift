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
        @Bindable var products = products
        let sections = products.filteredSections
        VStack(spacing: 0) {
            Divider()

            TabView(selection: $products.selectedCategoryIndex) {
                ForEach(sections.indices, id: \.self) { index in
                    CatalogGridView(section: sections[index],
                                 emptyTitle: products.isSearching ? SwiftGen.Catalog.Search.empty : nil,
                                 emptySystemImage: "magnifyingglass",
                                 emptyMessage: SwiftGen.Catalog.Search.changeQuery)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        }
    }
}

struct CategoryCollectionTab_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionTab()
            .environment(AppDIContainer.shared.makeCatalogViewModel())
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }
}
