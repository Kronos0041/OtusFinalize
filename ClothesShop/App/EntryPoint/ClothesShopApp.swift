//
//  ClothesShopApp.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

@main
struct ClothesShopApp: App {
    /// Контейнер сам настраивает Firebase до создания `Firestore` и первых экранов.
    private let container = AppDIContainer.shared

    init() {
        URLCache.shared = URLCache(memoryCapacity: 32 * 1024 * 1024,
                                   diskCapacity: 128 * 1024 * 1024,
                                   diskPath: "product-images")
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
