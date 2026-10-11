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
        let availableWidth = getWidth() - ComponentConstants.Layout.contentHorizontalInset
        return max(ComponentConstants.CategoryPicker.minItemWidth, availableWidth / CGFloat(count))
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
                            withAnimation(.easeInOut(duration: ComponentConstants.Animation.categorySwitchDuration)) {
                                products.selectedCategoryIndex = index
                            }
                        }
                        .id(index)
                    }
                }
            }
            .onChange(of: products.selectedCategoryIndex) { _, selected in
                withAnimation(.easeInOut(duration: ComponentConstants.Animation.categorySwitchDuration)) {
                    scroll.scrollTo(selected, anchor: .center)
                }
            }
        }
    }
}

#if DEBUG
struct CategoryCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryCollectionView()
                .environment(makeViewModel(PreviewData.catalog, selected: 1))
                .previewLayout(.sizeThatFits)
                .previewThemes("Помещаются на экран")
            CategoryCollectionView()
                .environment(makeViewModel(
                    PreviewData.catalog(categoryTitles: [
                        "Часы", "Ручки", "Очки", "Чемоданы", "Кожгалантерея", "Украшения"
                    ]),
                    selected: 5
                ))
                .previewLayout(.sizeThatFits)
                .previewThemes("Скролл")
        }
    }

    private static func makeViewModel(_ catalog: Catalog, selected: Int) -> CatalogViewModel {
        let viewModel = AppDIContainer.preview(catalog: .success(catalog)).makeLoadedCatalogViewModel()
        viewModel.selectedCategoryIndex = selected
        return viewModel
    }
}
#endif
