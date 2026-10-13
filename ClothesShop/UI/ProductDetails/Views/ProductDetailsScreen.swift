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
    @Environment(CatalogViewModel.self) private var catalogViewModel
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(Router<CatalogRoute>.self) private var router
    @State private var selectedSize: String?
    let productID: String

    init(productID: String, selectedSize: String? = nil) {
        self.productID = productID
        _selectedSize = State(initialValue: selectedSize)
    }

    private var mode: ViewMode<CatalogItemUIModel> { catalogViewModel.productMode(id: productID) }

    /// Актуальная версия товара после обновления каталога.
    private var current: CatalogItemUIModel? { catalogViewModel.product(id: productID) }

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
                    retry: { catalogViewModel.reload() }
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
                    .refreshable { await catalogViewModel.refresh() }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let current {
                    ProductPurchaseBar(
                        width: geometry.size.width,
                        isInCart: cartViewModel.item(productID: current.id, size: selectedSize) != nil,
                        canModifyCart: cartViewModel.canToggle(current, size: selectedSize),
                        isLiked: catalogViewModel.isFavorite(current),
                        toggleCart: { cartViewModel.toggle(current, size: selectedSize) },
                        toggleLike: { catalogViewModel.toggleFavorite(current) }
                    )
                }
            }
            .background(Color.appWhite)
            .foregroundColor(.appBlack)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { catalogViewModel.loadIfNeeded() }
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
