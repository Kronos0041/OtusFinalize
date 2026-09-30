//
//  ClothesShopApp.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI
import FirebaseCore

@main
struct ClothesShopApp: App {
    init() {
        URLCache.shared = URLCache(memoryCapacity: 32 * 1024 * 1024,
                                   diskCapacity: 128 * 1024 * 1024,
                                   diskPath: "product-images")
        // Firebase настраивается до создания первых экранов:
        // `AuthVM` при создании синхронно читает текущего пользователя.
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoadPreview()
        }
    }
}
