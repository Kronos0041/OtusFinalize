import SwiftUI

/// Сетка карточек товаров в две колонки, без собственной прокрутки.
struct CatalogProductsGrid: View {
    let items: [CatalogItemUIModel]

    @Environment(CatalogViewModel.self) private var catalogViewModel
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
        LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
            ForEach(items) { product in
                CatalogItemView(
                    item: product,
                    isLiked: catalogViewModel.isFavorite(product),
                    width: cellWidth,
                    topLike: { catalogViewModel.toggleFavorite(product) },
                    topDescription: { router.push(.productDetails(productID: product.id)) }
                )
            }
        }
        .frame(width: gridWidth)
    }
}
