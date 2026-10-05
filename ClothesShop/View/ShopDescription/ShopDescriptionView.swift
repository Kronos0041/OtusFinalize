//
//  ShopDescriptionView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Карточка товара с описанием, размерами и ценой.
/// Свайп вниз перезагружает каталог из Firestore; экран сразу показывает свежие данные товара.
struct ShopDescriptionView: View {
    @EnvironmentObject var products: MainGrideVM
    @EnvironmentObject private var cart: CartVM
    @State private var selectedSize: String?
    let product: MainGrideDateModel
    @Binding var backButton: Bool

    init(product: MainGrideDateModel, backButton: Binding<Bool>, selectedSize: String? = nil) {
        self.product = product
        _backButton = backButton
        _selectedSize = State(initialValue: selectedSize)
    }

    private var viewMode: ViewMode<MainGrideDateModel> { products.productViewMode(id: product.id) }

    /// Актуальная версия товара после обновления каталога.
    private var current: MainGrideDateModel { products.product(id: product.id) ?? product }

    private var canAddToCart: Bool {
        let validSize = current.sizes.isEmpty
            ? selectedSize == nil
            : current.sizes.contains(selectedSize ?? "")
        let quantity = cart.items.first { $0.product.id == current.id && $0.size == selectedSize }?.quantity ?? 0
        return validSize && quantity < CartVM.maximumQuantity
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TopBarDescriptionView(title: SwiftGen.Product.title,
                                      backButton: $backButton,
                                      frame: (width: geometry.size.width, height: 50))

                ViewModeView(viewMode,
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
                if viewMode.content != nil {
                    ProductPurchaseBar(width: geometry.size.width,
                                       canAddToCart: canAddToCart,
                                       isLiked: products.isLiked(current),
                                       addToCart: { cart.add(current, size: selectedSize) },
                                       toggleLike: { products.toggleLike(current) })
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
struct ShopDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        ShopDescriptionView(product: CartPreviewData.items[0].product,
                            backButton: .constant(false), selectedSize: "M")
            .environmentObject(MainGrideVM(previewProducts: CartPreviewData.items.map(\.product)))
            .environmentObject(CartVM(ownerID: nil))
            .previewThemes()
    }
}
#endif
