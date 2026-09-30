//
//  UIService.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Общие размеры, которые раньше были разбросаны по экранам магическими числами.
enum AppLayout {
    static let sideInset: CGFloat = 40
    static let buttonHeight: CGFloat = 50

    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }

    /// Кнопка на всю ширину экрана с отступами.
    static var fullWidthButton: (width: CGFloat, height: CGFloat) {
        (screenWidth - sideInset, buttonHeight)
    }
}

extension View {
    func getWidth() -> CGFloat { AppLayout.screenWidth }
    func getHeight() -> CGFloat { AppLayout.screenHeight }

    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

/// Считывает размер вью в переданный биндинг.
struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.onAppear { size = proxy.size }
            }
        )
    }
}

extension Image {
    init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String),
              let image = UIImage(data: data) else { return nil }
        self = Image(uiImage: image)
    }
}
