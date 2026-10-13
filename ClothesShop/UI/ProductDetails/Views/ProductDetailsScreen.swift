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
    @Environment(Router<CatalogRoute>.self) private var router
    @State private var selectedSize: String?
    let productID: String

    init(productID: String, selectedSize: String? = nil) {
        self.productID = productID
        _selectedSize = State(initialValue: selectedSize)
    }

    private var mode: ViewMode<CatalogItemUIModel> { products.productMode(id: productID) }

    /// Актуальная версия товара после обновления каталога.
    private var current: CatalogItemUIModel? { products.product(id: productID) }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TopBarDescriptionView(
                    title: SwiftGen.Product.title,
                    onBack: { router.pop() },
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
    static var previews: some View {
        Group {
            screen(PreviewData.watch.id, size: "M", .mock(cartItems: []))
                .previewThemes("Размер выбран")
            screen(PreviewData.watch.id, .mock(cartItems: []))
                .previewThemes("Размер не выбран")
            screen(PreviewData.glasses.id, .mock(cartItems: []))
                .previewThemes("Без размеров")
            screen(
                PreviewData.longContent.id,
                size: "XL",
                .mock(catalog: .success(Catalog(
                    categories: PreviewData.categories,
                    products: [PreviewData.longContent]
                )), cartItems: [])
            )
                .previewThemes("Длинные тексты")
            screen(PreviewData.watch.id, .mock(catalog: .loading, cartItems: []))
                .previewThemes("Загрузка")
            screen("missing", .mock(cartItems: []))
                .previewThemes("Товар не найден")
            screen(PreviewData.watch.id, .mock(isConnected: false, cartItems: []))
                .previewThemes("Нет сети")
            screen(
                PreviewData.watch.id,
                .mock(catalog: .failure(MockError("Сервер недоступен")), cartItems: [])
            )
                .previewThemes("Ошибка")
        }
    }

    private static func screen(
        _ productID: String,
        size: String? = nil,
        _ container: AppDIContainer
    ) -> some View {
        ProductDetailsScreen(productID: productID, selectedSize: size)
            .environment(container.makeLoadedCatalogViewModel())
            .environment(container.makeLoadedCartViewModel())
            .environment(Router<CatalogRoute>())
    }
}
#endif
