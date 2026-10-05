//
//  MainGridView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Сетка товаров одного раздела.
struct MainGridView: View {
    let section: ShopItemModel
    var emptyTitle: String? = nil
    var emptySystemImage = "heart"
    var emptyMessage = SwiftGen.Favorites.instructions
    @EnvironmentObject var products: MainGrideVM

    @State private var showDescription = false
    @State private var openedProduct: MainGrideDateModel?

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
                    ShopDescriptionView(product: product, backButton: $showDescription)
                        .environmentObject(products)
                }
            } label: {
                EmptyView()
            }

            if section.product.isEmpty, let emptyTitle {
                StatePlaceholder(systemImage: emptySystemImage, title: emptyTitle,
                                 message: Text(emptyMessage))
            }

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
                    ForEach(section.product) { product in
                        MainGridCellView(item: product,
                                         isLiked: products.isLiked(product),
                                         frame: cellSize,
                                         topLike: { products.toggleLike(product) },
                                         topDescription: { open(product) })
                    }
                }
                .padding(.top, 10)
            }
            // На iOS 15 ScrollView не поддерживает pull-to-refresh — модификатор просто
            // ничего не делает; с iOS 16 работает. На карточке товара (List) — с iOS 15.
            .refreshable { await products.refresh() }
            .allowsHitTesting(!section.product.isEmpty)
        }
        .frame(width: gridWidth)
    }

    private func open(_ product: MainGrideDateModel) {
        openedProduct = product
        showDescription.toggle()
    }
}

struct MainGridView_Previews: PreviewProvider {
    static var previews: some View {
        let section = ShopItemModel(id: "preview",
                                    categoryName: .init(id: "preview", title: "Пример"),
                                    product: [])
        let viewModel = MainGrideVM()
        MainGridView(section: section)
            .environmentObject(viewModel)
            .previewThemes()
    }
}
