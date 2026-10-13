//
//  SplashView.swift
//  ClothesShop
//
//  Created by Alex on 13.10.2026.
//

import SwiftUI

/// Заставка при запуске поверх приложения: логотип делает оборот, затем заставка растворяется.
/// Флагов и колбэков нет — состояние только у самой анимации (угол и прозрачность).
/// После неё заставка прозрачна и не перехватывает нажатия, а под ней уже открыт каталог или вход.
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var logoRotation: Double = 0
    @State private var opacity: Double = 1

    private typealias Constants = ComponentConstants.Splash

    var body: some View {
        ZStack {
            BlurredWallpaperBackground()

            VStack(spacing: 0) {
                Image(AppImage.brandLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .background(Color.appBlack)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(logoRotation))

                Text(verbatim: "Montblanc")
                    .font(.babylonica(size: 54))
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear(perform: animate)
    }

    /// Оборот стартует сразу, без задержки; растворение — сразу после него.
    /// При «Уменьшении движения» логотип стоит на месте, остаются пауза и растворение.
    private func animate() {
        if !reduceMotion {
            withAnimation(.easeInOut(duration: Constants.rotationDuration)) {
                logoRotation = 360
            }
        }
        withAnimation(.easeOut(duration: Constants.fadeDuration).delay(Constants.rotationDuration)) {
            opacity = 0
        }
    }
}

#if DEBUG
/// Заставка растворяется сама, поэтому превью пересоздаёт её каждые 2 с — анимация идёт по кругу.
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(.periodic(from: .now, by: 2)) { context in
            SplashView()
                .id(context.date)
        }
        .previewThemes()
    }
}
#endif
