//
//  CatalogGridView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Сетка товаров одного раздела.
struct CatalogGridView: View {
    let section: CatalogSectionUIModel
    var emptyTitle: String? = nil
    var emptySystemImage = "heart"
    var emptyMessage = SwiftGen.Favorites.instructions
    var header: CatalogHeaderView? = nil

    @Environment(CatalogViewModel.self) private var products
    @Environment(Router<CatalogRoute>.self) private var router

    private let itemSpacing: CGFloat = 12

    private var gridWidth: CGFloat { getWidth() - ComponentConstants.Layout.contentHorizontalInset }

    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: itemSpacing, alignment: .top),
         GridItem(.flexible(), spacing: itemSpacing, alignment: .top)]
    }

    private var cellWidth: CGFloat {
        (gridWidth - itemSpacing) / 2
    }

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
                VStack(spacing: 0) {
                    if let header {
                        header
                    }

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                        ForEach(section.products) { product in
                            CatalogItemView(
                                item: product,
                                isLiked: products.isFavorite(product),
                                width: cellWidth,
                                topLike: { products.toggleFavorite(product) },
                                topDescription: { router.push(.productDetails(productID: product.id)) }
                            )
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .refreshable { await products.refresh() }
            .allowsHitTesting(header != nil || !section.products.isEmpty)
        }
        .frame(width: gridWidth)
    }
}

#if DEBUG
struct CatalogGridView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppDIContainer.preview(favoriteIDs: [PreviewData.watch.id])
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
