//
//  AppFont.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Шрифты приложения.
///
/// Каталог ассетов шрифты не поддерживает, поэтому `.ttf` лежат в папке `Font`, входят
/// в ресурсы бандла и регистрируются через `UIAppFonts` в `Info.plist`.
/// Здесь — единственное место, где упоминается имя шрифта.
extension Font {
    /// Рукописный шрифт логотипа.
    static func babylonica(size: CGFloat) -> Font {
        .custom("Babylonica", size: size)
    }
}
