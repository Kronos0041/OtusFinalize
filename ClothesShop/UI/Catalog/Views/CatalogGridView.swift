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
    var header: CatalogHeaderView? = nil

    @Environment(CatalogViewModel.self) private var products
    @Environment(Router<CatalogRoute>.self) private var router

    private let itemSpacing: CGFloat = 12

    private var gridWidth: CGFloat { getWidth() - 20 }

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

struct CatalogGridView_Previews: PreviewProvider {
    private static let previewProducts = [
        makeProduct(id: "watch-moonphase-rose", categoryID: "watches",
                    image: "watch-moonphase-rose.png?v=c762e51f76c9",
                    title: "Moonphase Rose", details: "Розовое золото, фаза луны",
                    price: 245_000, badge: "Новинка"),
        makeProduct(id: "pen-classic-black", categoryID: "pens",
                    image: "pen-classic-black.png?v=9d0c4d363d09",
                    title: "Перьевая ручка Classic Black", details: "Чёрная смола, золотое перо",
                    price: 79_000, badge: "Персонализация"),
        makeProduct(id: "luggage-cabin-black", categoryID: "luggage",
                    image: "luggage-cabin-black.png?v=104396fbe5cd",
                    title: "Чемодан-кабина Black", details: "Ручная кладь, поликарбонат",
                    price: 89_000),
        makeProduct(id: "glasses-navigator", categoryID: "glasses",
                    image: "glasses-navigator.png?v=48d43a195b88",
                    title: "Авиаторы Navigator", details: "Графитовые линзы, двойной мост",
                    price: 32_900),
        makeProduct(id: "watch-bronze-green", categoryID: "watches",
                    image: "watch-bronze-green.png?v=aaded53fadfd",
                    title: "Хронограф Bronze Green", details: "Бронзовый корпус, зелёный ремешок",
                    price: 198_000),
        makeProduct(id: "pen-blue-resin", categoryID: "pens",
                    image: "pen-blue-resin.png?v=9ef55a827b55",
                    title: "Перьевая ручка Blue Resin", details: "Синий корпус, серебристый колпачок",
                    price: 54_000),
        makeProduct(id: "glasses-panto-rose", categoryID: "glasses",
                    image: "glasses-panto-rose.png?v=86197f3ff8d1",
                    title: "Панто Rose", details: "Светлая оправа, голубые линзы",
                    price: 28_500),
        makeProduct(id: "luggage-medium-black", categoryID: "luggage",
                    image: "luggage-medium-black.png?v=83f17879befd",
                    title: "Чемодан Medium Black", details: "Средний размер для поездки на неделю",
                    price: 99_000)
    ]

    static var previews: some View {
        let section = CatalogSectionViewModel(
            id: "preview",
            category: .init(id: "preview", title: "Пример"),
            products: previewProducts
        )
        let viewModel = AppDIContainer.shared.makeCatalogViewModel(automaticallyReloads: false)
        viewModel.applyPreview(
            products: previewProducts,
            favoriteIDs: [previewProducts[0].id]
        )

        return CatalogGridView(section: section)
            .environment(viewModel)
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }

    private static func makeProduct(
        id: String,
        categoryID: String,
        image: String,
        title: String,
        details: String,
        price: Int,
        badge: String? = nil
    ) -> CatalogItemViewModel {
        CatalogItemViewModel(
            id: id,
            categoryID: categoryID,
            imageURL: URL(string: "https://test-6d334.web.app/products/\(image)"),
            title: title,
            shortDescription: details,
            description: details,
            price: price,
            sizes: [],
            badge: badge
        )
    }
}
