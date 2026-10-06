//
//  CatalogItemView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Карточка товара: фото, кнопка «лайк», название и краткое описание.
struct CatalogItemView: View {
    let item: CatalogItemViewModel
    let isLiked: Bool
    let frame: (w: CGFloat, h: CGFloat)

    let topLike: () -> Void
    let topDescription: () -> Void

    var body: some View {
        VStack {
            productImage
                .frame(width: frame.w, height: frame.w)
                .background(Color.appGray.opacity(0.2))
                .cornerRadius(15)
                .overlay(likeButton)

            HStack {
                Text(item.title)
                    .bold()
                    .lineLimit(2)
                    .font(.system(size: 18, design: .serif))
                Spacer()
            }

            HStack {
                Text(item.shortDescription)
                    .lineLimit(2)
                    .foregroundColor(Color.appGray)
                    .font(.system(size: 16, design: .serif))
                Spacer()
            }

            Spacer()
        }
        .frame(width: frame.w, height: frame.h, alignment: .leading)
        .onTapGesture(perform: topDescription)
    }

    private var productImage: some View {
        RemoteImageView(url: item.imageURL)
            .accessibilityLabel(Text(item.title))
    }

    private var likeButton: some View {
        Button(action: topLike) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
            .resizable()
            .scaledToFit()
            .foregroundColor(isLiked ? Color.appRed : Color.appGray)
            .frame(width: 20, height: 20)
            .frame(width: 50, height: 50)
            .background(Color.appWhite)
            .cornerRadius(15)
            .padding()
            .offset(x: frame.w / 2 - 35, y: -frame.w / 2 + 35)
            .shadow(color: Color.appGray.opacity(0.3), radius: 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? Text(SwiftGen.Favorites.remove) : Text(SwiftGen.Favorites.add))
    }
}

struct CatalogItemView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogItemView(item: CatalogItemViewModel(id: "preview",
                                                  categoryID: "preview",
                                                  imageURL: nil,
                                                  title: "Товар",
                                                  shortDescription: "Краткое описание",
                                                  description: "Описание",
                                                  price: 10_000,
                                                  sizes: []),
                         isLiked: false,
                         frame: ((UIScreen.main.bounds.width - 20) / 2, UIScreen.main.bounds.width / 2 + 90),
                         topLike: {},
                         topDescription: {})
            .previewThemes()
    }
}
