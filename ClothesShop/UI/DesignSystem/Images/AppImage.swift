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
/// Цвета берутся из символов, которые Xcode генерирует по `Assets.xcassets` (`Color.appBlack`).
/// Для картинок такие же символы есть (`Image(.brandLogo)`), но здесь пока используются строковые имена.
enum AppImage {
    static let brandLogo = "brandLogo"

    enum Wallpaper {
        static let background = "backgroundWallpaper"
    }

}
