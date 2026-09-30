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
    let product: MainGrideDateModel
    @Binding var backButton: Bool

    /// Актуальная версия товара после обновления каталога.
    private var current: MainGrideDateModel { products.product(id: product.id) ?? product }
    private var contentWidth: CGFloat { getWidth() - AppLayout.sideInset }

    var body: some View {
        VStack {
            TopBarDescriptionView(title: "О товаре",
                                  backButton: $backButton,
                                  frame: (width: getWidth() - 20, height: 50))

            List {
                VStack(spacing: 20) {
                    MainGridCellView(item: current,
                                     isLiked: products.isLiked(current),
                                     frame: (w: contentWidth, h: getWidth()),
                                     topLike: { products.toggleLike(current) },
                                     topDescription: {})

                    Text(verbatim: current.description)
                        .frame(width: contentWidth, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.appGray)

                    if !current.sizes.isEmpty {
                        Text("Размер")
                            .bold()
                            .foregroundColor(.appBlack)
                            .font(.system(size: 18, design: .serif))
                            .frame(width: contentWidth, alignment: .leading)

                        SizeCollection(sizes: current.sizes)
                    }

                    Divider()

                    priceRow
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .refreshable { await products.refresh() }
        }
        .navigationBarHidden(true)
    }

    private var priceRow: some View {
        HStack {
            VStack {
                priceText(Text("Цена"), size: 24, color: Color.appBlack.opacity(0.7))
                priceText(Text(verbatim: current.formattedPrice), size: 28, color: .appBlack)
            }

            Spacer()

            ButtonView(model: .magazin,
                       state: .activeBlack,
                       frame: (width: getWidth() / 2, height: AppLayout.buttonHeight),
                       imageLeft: AppImage.Icon.cart)
        }
        .frame(width: contentWidth, alignment: .leading)
    }

    private func priceText(_ text: Text, size: CGFloat, color: Color) -> some View {
        text
            .bold()
            .foregroundColor(color)
            .font(.system(size: size, design: .serif))
            .multilineTextAlignment(.leading)
            .frame(width: getWidth() / 3, alignment: .leading)
    }
}

struct ShopDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        ShopDescriptionView(product: MainGrideDateModel(id: "preview",
                                                        categoryId: "watches",
                                                        imageURL: nil,
                                                        title: "Moonphase Rose",
                                                        shortDescription: "Розовое золото, фаза луны",
                                                        description: "Часы с индикатором фазы луны.",
                                                        price: 245_000,
                                                        sizes: ["S", "M", "L"]),
                            backButton: .constant(false))
            .environmentObject(MainGrideVM())
    }
}
