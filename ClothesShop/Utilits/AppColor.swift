//
//  AppColor.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Цвета лежат в `Assets.xcassets/AppColor` (со светлой и тёмной темой).
/// Здесь только типизированный доступ к ним, чтобы не писать имя ассета строкой.
///
/// Xcode умеет генерировать такие символы сам (`Color.appBlack`), но они требуют iOS 17,
/// а проект поддерживает iOS 15. Имена ниже совпадают со сгенерированными: после подъёма
/// минимальной версии этот файл удаляется, а вызовы `.appBlack` остаются без изменений.
/// До тех пор генерация Swift-расширений отключена в настройках проекта
/// (`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO`), чтобы имена не конфликтовали.
extension Color {
    static let appBlack = Color("AppBlack")
    static let appWhite = Color("AppWhite")
    static let appGray = Color("AppGray")
    static let appSliver = Color("AppSliver")
    static let appRed = Color("AppRed")
}
