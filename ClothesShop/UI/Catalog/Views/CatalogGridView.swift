//
//  CatalogGridView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Сетка товаров одного раздела.
struct CatalogGridView: View {
    let section: CatalogSectionViewModel
    var emptyTitle: String? = nil
    var emptySystemImage = "heart"
    var emptyMessage = SwiftGen.Favorites.instructions

    @Environment(CatalogViewModel.self) private var products
    @Environment(Router<CatalogRoute>.self) private var router

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 0),
                           GridItem(.adaptive(minimum: 150), spacing: 0)]

    private var gridWidth: CGFloat { getWidth() - 20 }

    private var cellSize: (w: CGFloat, h: CGFloat) {
        ((gridWidth - 20) / 2, gridWidth / 2 + 90)
    }

    var body: some View {
        ZStack {
            if section.products.isEmpty, let emptyTitle {
                StatePlaceholder(systemImage: emptySystemImage, title: emptyTitle,
                                 message: Text(emptyMessage))
            }

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
                    ForEach(section.products) { product in
                        CatalogItemView(item: product,
                                        isLiked: products.isFavorite(product),
                                        frame: cellSize,
                                        topLike: { products.toggleFavorite(product) },
                                        topDescription: { router.push(.productDetails(productID: product.id)) })
                    }
                }
                .padding(.top, 10)
            }
            .refreshable { await products.refresh() }
            .allowsHitTesting(!section.products.isEmpty)
        }
        .frame(width: gridWidth)
    }
}

struct CatalogGridView_Previews: PreviewProvider {
    static var previews: some View {
        let section = CatalogSectionViewModel(id: "preview",
                                    category: .init(id: "preview", title: "Пример"),
                                    products: [])
        let viewModel = AppDIContainer.shared.makeCatalogViewModel()
        CatalogGridView(section: section)
            .environment(viewModel)
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }
}
