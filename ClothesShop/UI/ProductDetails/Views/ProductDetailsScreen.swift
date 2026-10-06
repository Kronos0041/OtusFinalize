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
    @EnvironmentObject var products: CatalogViewModel
    @EnvironmentObject private var cart: CartViewModel
    @State private var selectedSize: String?
    let product: CatalogItemViewModel
    @Binding var backButton: Bool

    init(product: CatalogItemViewModel, backButton: Binding<Bool>, selectedSize: String? = nil) {
        self.product = product
        _backButton = backButton
        _selectedSize = State(initialValue: selectedSize)
    }

    private var mode: ViewMode<CatalogItemViewModel> { products.productMode(id: product.id) }

    /// Актуальная версия товара после обновления каталога.
    private var current: CatalogItemViewModel { products.product(id: product.id) ?? product }

    private var cartItem: CartItemViewModel? {
        cart.items.first { $0.product.id == current.id && $0.size == selectedSize }
    }

    private var canModifyCart: Bool {
        guard cart.isLoaded else { return false }
        if cartItem != nil { return true }
        let validSize = current.sizes.isEmpty
            ? selectedSize == nil
            : current.sizes.contains(selectedSize ?? "")
        return validSize
    }

    private func toggleCart() {
        if let cartItem {
            cart.remove(cartItem.id)
        } else {
            cart.add(current, size: selectedSize)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TopBarDescriptionView(title: SwiftGen.Product.title,
                                      backButton: $backButton,
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
                if mode.content != nil {
                    ProductPurchaseBar(width: geometry.size.width,
                                       isInCart: cartItem != nil,
                                       canModifyCart: canModifyCart,
                                       isLiked: products.isFavorite(current),
                                       toggleCart: toggleCart,
                                       toggleLike: { products.toggleFavorite(current) })
                }
            }
            .background(Color.appWhite)
            .foregroundColor(.appBlack)
        }
        .navigationBarHidden(true)
        .onAppear { products.loadIfNeeded() }
        .onChange(of: current.sizes) { sizes in
            if let selectedSize, !sizes.contains(selectedSize) { self.selectedSize = nil }
        }
    }
}

#if DEBUG
struct ProductDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        let catalog = AppDIContainer.shared.makeCatalogViewModel()
        catalog.applyPreview(products: CartPreviewData.items.map(\.product))
        return ProductDetailsScreen(product: CartPreviewData.items[0].product,
                            backButton: .constant(false), selectedSize: "M")
            .environmentObject(catalog)
            .environmentObject(CartPreviewData.makeCart(isEmpty: true))
            .previewThemes()
    }
}
#endif
