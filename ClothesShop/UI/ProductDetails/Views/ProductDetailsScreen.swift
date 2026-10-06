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
                TopBarDescriptionView(
                    title: SwiftGen.Product.title,
                    onBack: { dismiss() },
                    frame: (width: geometry.size.width, height: 50)
                )

                ViewModeView(
                    mode,
                    emptyTitle: SwiftGen.Common.empty,
                    retry: { products.reload() }
                ) { loadedProduct in
                    List {
                        ProductDetailsView(
                            product: loadedProduct,
                            selectedSize: $selectedSize,
                            imageSize: geometry.size.width
                        )
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
                    ProductPurchaseBar(
                        width: geometry.size.width,
                        isInCart: cart.item(productID: current.id, size: selectedSize) != nil,
                        canModifyCart: cart.canToggle(current, size: selectedSize),
                        isLiked: products.isFavorite(current),
                        toggleCart: { cart.toggle(current, size: selectedSize) },
                        toggleLike: { products.toggleFavorite(current) }
                    )
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
    private static func content(_ product: CatalogItemViewModel, size: String?) -> some View {
        let catalog = AppDIContainer.shared.makeCatalogViewModel()
        catalog.applyPreview(products: [product])
        return ProductDetailsScreen(productID: product.id, selectedSize: size)
            .environment(catalog)
            .environment(CartPreviewData.makeCart(isEmpty: true))
    }

    private static func state(_ mode: ViewMode<[CatalogSectionViewModel]>) -> some View {
        let catalog = AppDIContainer.shared.makeCatalogViewModel()
        catalog.applyPreview(mode: mode)
        return ProductDetailsScreen(productID: CartPreviewData.items[0].product.id)
            .environment(catalog)
            .environment(CartPreviewData.makeCart(isEmpty: true))
    }

    static var previews: some View {
        Group {
            content(CartPreviewData.items[0].product, size: "M")
                .previewThemes("Размер выбран")
            content(CartPreviewData.items[0].product, size: nil)
                .previewThemes("Размер не выбран")
            content(CartPreviewData.productWithoutSizes, size: nil)
                .previewThemes("Без размеров")
            content(CartPreviewData.productLongContent, size: "XL")
                .previewThemes("Длинные тексты")
            state(.loading).previewThemes("Загрузка")
            state(.empty).previewThemes("Товар не найден")
            state(.noInternet).previewThemes("Нет сети")
            state(.error("Сервер недоступен")).previewThemes("Ошибка")
        }
    }
}
#endif
