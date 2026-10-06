//
//  ProductDetailsScreen.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Карточка товара с описанием, размерами и ценой.
/// Свайп вниз перезагружает каталог из Firestore; экран сразу показывает свежие данные товара.
struct ProductDetailsScreen: View {
    @Environment(CatalogViewModel.self) private var products
    @Environment(CartViewModel.self) private var cart
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSize: String?
    let productID: String

    init(productID: String, selectedSize: String? = nil) {
        self.productID = productID
        _selectedSize = State(initialValue: selectedSize)
    }

    private var mode: ViewMode<CatalogItemViewModel> { products.productMode(id: productID) }

    /// Актуальная версия товара после обновления каталога.
    private var current: CatalogItemViewModel? { products.product(id: productID) }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TopBarDescriptionView(title: SwiftGen.Product.title,
                                      onBack: { dismiss() },
                                      frame: (width: geometry.size.width, height: 50))

                ViewModeView(mode,
                             emptyTitle: SwiftGen.Common.empty,
                             retry: { products.reload() }) { loadedProduct in
                    List {
                        ProductDetailsView(product: loadedProduct, selectedSize: $selectedSize,
                                           imageSize: geometry.size.width)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appWhite)
                    }
                    .listStyle(.plain)
                    .refreshable { await products.refresh() }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let current {
                    ProductPurchaseBar(width: geometry.size.width,
                                       isInCart: cart.item(productID: current.id, size: selectedSize) != nil,
                                       canModifyCart: cart.canToggle(current, size: selectedSize),
                                       isLiked: products.isFavorite(current),
                                       toggleCart: { cart.toggle(current, size: selectedSize) },
                                       toggleLike: { products.toggleFavorite(current) })
                }
            }
            .background(Color.appWhite)
            .foregroundColor(.appBlack)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { products.loadIfNeeded() }
        .onChange(of: current?.sizes ?? []) { _, sizes in
            if let selectedSize, !sizes.contains(selectedSize) { self.selectedSize = nil }
        }
    }
}

#if DEBUG
struct ProductDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        let catalog = AppDIContainer.shared.makeCatalogViewModel()
        catalog.applyPreview(products: CartPreviewData.items.map(\.product))
        return ProductDetailsScreen(productID: CartPreviewData.items[0].product.id, selectedSize: "M")
            .environment(catalog)
            .environment(CartPreviewData.makeCart(isEmpty: true))
            .previewThemes()
    }
}
#endif
