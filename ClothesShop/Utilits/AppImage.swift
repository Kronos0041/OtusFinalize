//
//  AppImage.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation

/// Имена картинок интерфейса из `Assets.xcassets/AppImage`.
///
/// Фото товаров сюда не входят: их URL приходят из Firestore (`ProductDTO.imageURL`).
/// Типизированные `ImageResource` от Xcode требуют iOS 17 — см. комментарий в `AppColor.swift`.
enum AppImage {
    static let brandLogo = "brandLogo"

    enum Wallpaper {
        static let background = "backgroundWallpaper"
    }

    enum Icon {
        static let next = "iconNext"
        static let cart = "iconCart"
    }
}
