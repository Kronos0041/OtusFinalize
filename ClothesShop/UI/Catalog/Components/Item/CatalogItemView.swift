//
//  CatalogItemView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Карточка товара: фото, избранное, метка, название, цена и краткое описание.
struct CatalogItemView: View {
    let item: CatalogItemViewModel
    let isLiked: Bool
    let width: CGFloat

    let topLike: () -> Void
    let topDescription: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            productImage
                .frame(width: width, height: width)
                .overlay(alignment: .topTrailing) { likeButton }

            if let badge = item.badge {
                Text(badge.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.8)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appGray.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .padding(.horizontal, 8)
            }

            Text(item.title)
                .font(.system(size: 16))
                .lineLimit(2)
                .padding(.horizontal, 8)

            Text(item.formattedPrice)
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 8)

            Text(item.shortDescription)
                .font(.system(size: 14))
                .foregroundColor(.appGray)
                .lineLimit(2)
                .padding(.horizontal, 8)
        }
        .padding(.bottom, 10)
        .frame(width: width, alignment: .topLeading)
        .background(Color.appGray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .foregroundColor(.appBlack)
        .contentShape(Rectangle())
        .onTapGesture(perform: topDescription)
    }

    private var productImage: some View {
        RemoteImageView(url: item.imageURL, contentMode: .fit)
            .accessibilityLabel(Text(item.title))
    }

    private var likeButton: some View {
        Button(action: topLike) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(isLiked ? .appRed : .appBlack)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .padding(4)
        .accessibilityLabel(isLiked ? Text(SwiftGen.Favorites.remove) : Text(SwiftGen.Favorites.add))
    }
}

struct CatalogItemView_Previews: PreviewProvider {
    private static let width = (UIScreen.main.bounds.width - 32) / 2

    static var previews: some View {
        Group {
            card(
                item: makeItem(
                    id: "short",
                    image: "pen-classic-black.png?v=9d0c4d363d09",
                    title: "Ручка",
                    details: "Чёрная смола",
                    price: 990
                )
            )
            .previewThemes("Короткий текст · маленькая цена")

            card(
                item: makeItem(
                    id: "regular",
                    image: "watch-moonphase-rose.png?v=c762e51f76c9",
                    title: "Moonphase Rose",
                    details: "Розовое золото, фаза луны",
                    price: 245_000,
                    badge: "Новинка"
                )
            )
            .previewThemes("Обычная карточка")

            card(
                item: makeItem(
                    id: "long",
                    image: "luggage-medium-black.png?v=83f17879befd",
                    title: "Чемодан Medium Black Limited Edition для длительных путешествий",
                    details: "Средний размер, усиленный корпус, кодовый замок и дополнительные отделения",
                    price: 12_450_000,
                    badge: "Персонализация"
                ),
                isLiked: true
            )
            .previewThemes("Длинный текст · большая цена")
        }
    }

    private static func card(
        item: CatalogItemViewModel,
        isLiked: Bool = false
    ) -> some View {
        CatalogItemView(
            item: item,
            isLiked: isLiked,
            width: width,
            topLike: {},
            topDescription: {}
        )
        .padding(20)
        .previewLayout(.sizeThatFits)
    }

    private static func makeItem(
        id: String,
        image: String,
        title: String,
        details: String,
        price: Int,
        badge: String? = nil
    ) -> CatalogItemViewModel {
        CatalogItemViewModel(
            id: id,
            categoryID: "preview",
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
