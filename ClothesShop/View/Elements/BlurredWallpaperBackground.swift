//
//  BlurredWallpaperBackground.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Размытые обои — общий фон стартового экрана и экрана авторизации.
struct BlurredWallpaperBackground: View {
    var imageName: String = AppImage.Wallpaper.background

    var body: some View {
        Image(imageName)
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .overlay(
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.appWhite.opacity(0.1))
                        .edgesIgnoringSafeArea(.all)
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
