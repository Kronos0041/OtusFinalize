//
//  CatalogGridView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Прокручиваемая сетка товаров одного раздела с заглушкой для пустого списка.
struct CatalogGridView: View {
    let section: CatalogSectionUIModel
    var emptyTitle: String? = nil
    var emptySystemImage = "heart"
    var emptyMessage = SwiftGen.Favorites.instructions

    @Environment(CatalogViewModel.self) private var catalogViewModel

    var body: some View {
        ZStack {
            if section.products.isEmpty, let emptyTitle {
                StatePlaceholder(
                    systemImage: emptySystemImage,
                    title: emptyTitle,
                    message: Text(emptyMessage)
                )
            }

            ScrollView(.vertical, showsIndicators: false) {
                CatalogProductsGrid(items: section.products)
                    .padding(.top, 10)
            }
            .refreshable { await catalogViewModel.refresh() }
            .allowsHitTesting(!section.products.isEmpty)
        }
    }
}

#if DEBUG
struct CatalogGridView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppDIContainer.mock(favoriteIDs: [PreviewData.watch.id])
        let section = CatalogSectionUIModel(
            id: "preview",
            category: .init(id: "preview", title: "Пример"),
            products: PreviewData.catalogItems
        )
        return CatalogGridView(section: section)
            .environment(container.makeLoadedCatalogViewModel())
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }
}
#endif
