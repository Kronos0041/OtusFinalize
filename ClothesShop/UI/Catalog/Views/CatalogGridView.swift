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
    @EnvironmentObject var products: CatalogViewModel

    @State private var showDescription = false
    @State private var openedProduct: CatalogItemViewModel?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 0),
                           GridItem(.adaptive(minimum: 150), spacing: 0)]

    private var gridWidth: CGFloat { getWidth() - 20 }
    private var cellSize: (w: CGFloat, h: CGFloat) {
        ((gridWidth - 20) / 2, gridWidth / 2 + 90)
    }

    var body: some View {
        ZStack {
            NavigationLink(isActive: $showDescription) {
                if let product = openedProduct {
                    ProductDetailsScreen(product: product, backButton: $showDescription)
                        .environmentObject(products)
                }
            } label: {
                EmptyView()
            }

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
                                         topDescription: { open(product) })
                    }
                }
                .padding(.top, 10)
            }
            // На iOS 15 ScrollView не поддерживает pull-to-refresh — модификатор просто
            // ничего не делает; с iOS 16 работает. На карточке товара (List) — с iOS 15.
            .refreshable { await products.refresh() }
            .allowsHitTesting(!section.products.isEmpty)
        }
        .frame(width: gridWidth)
    }

    private func open(_ product: CatalogItemViewModel) {
        openedProduct = product
        showDescription.toggle()
    }
}

struct CatalogGridView_Previews: PreviewProvider {
    static var previews: some View {
        let section = CatalogSectionViewModel(id: "preview",
                                    category: .init(id: "preview", title: "Пример"),
                                    products: [])
        let viewModel = AppDIContainer.shared.makeCatalogViewModel()
        CatalogGridView(section: section)
            .environmentObject(viewModel)
            .previewThemes()
    }
}
