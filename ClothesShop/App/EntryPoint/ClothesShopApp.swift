//
//  ClothesShopApp.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

@main
struct ClothesShopApp: App {
    /// Контейнер сам настраивает Firebase и кэш картинок до создания первых экранов.
    private let container = AppDIContainer.shared

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
