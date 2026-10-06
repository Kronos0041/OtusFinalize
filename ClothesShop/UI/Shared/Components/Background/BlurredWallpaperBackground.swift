//
//  BlurredWallpaperBackground.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Размытые обои — общий фон стартового экрана и экрана авторизации.
struct BlurredWallpaperBackground: View {
    private let imageName = AppImage.Wallpaper.background

    var body: some View {
        Image(imageName)
            .resizable()
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.appWhite.opacity(0.1))
                        .ignoresSafeArea()
                }
                .background(.ultraThinMaterial)
            )
    }
}

struct BlurredWallpaperBackground_Previews: PreviewProvider {
    static var previews: some View {
        BlurredWallpaperBackground()
            .previewThemes()
    }
}
