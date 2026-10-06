//
//  CategoryCollectionView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Горизонтальная лента категорий над каталогом.
struct CategoryCollectionView: View {
    @Environment(CatalogViewModel.self) private var products

    private var itemWidth: CGFloat {
        let count = max(products.sections.count, 1)
        return max(70, (getWidth() - 20) / CGFloat(count))
    }

    var body: some View {
        ScrollViewReader { scroll in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    // id — индекс раздела: по нему работает scrollTo(selected).
                    ForEach(products.sections.indices, id: \.self) { index in
                        CategoryCollectionCellView(
                            item: products.sections[index].category,
                            isSelected: products.isSelected(index),
                            width: itemWidth
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                products.selectedCategoryIndex = index
                            }
                        }
                        .id(index)
                    }
                }
            }
            .onChange(of: products.selectedCategoryIndex) { _, selected in
                withAnimation(.easeInOut(duration: 0.2)) {
                    scroll.scrollTo(selected, anchor: .center)
                }
            }
        }
    }
}

struct CategoryCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionView()
            .environment(AppDIContainer.shared.makeCatalogViewModel())
            .previewThemes()
    }
}
