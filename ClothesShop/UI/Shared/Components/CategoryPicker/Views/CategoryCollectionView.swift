//
//  CategoryCollectionView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Горизонтальная лента категорий над каталогом.
struct CategoryCollectionView: View {
    @EnvironmentObject var products: CatalogViewModel

    var body: some View {
        ScrollViewReader { scroll in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    // id — индекс раздела: по нему работает scrollTo(selected).
                    ForEach(products.sections.indices, id: \.self) { index in
                        CategoryCollectionCellView(item: products.sections[index].category,
                                                   isSelected: products.isSelected(index)) {
                            products.selectedCategoryIndex = index
                        }
                    }
                }
            }
            .onChange(of: products.selectedCategoryIndex) { selected in
                scroll.scrollTo(selected)
            }
        }
    }
}

struct CategoryCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionView()
            .environmentObject(AppDIContainer.shared.makeCatalogViewModel())
            .previewThemes()
    }
}
