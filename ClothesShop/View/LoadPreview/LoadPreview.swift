//
//  LoadPreview.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Стартовый экран: логотип и выбор «вход / регистрация».
/// Если пользователь уже авторизован, сразу открывается `TabViewContent`.
struct LoadPreview: View {
    @StateObject private var auth = AuthVM()
    @State private var viewState: AuthState = .reg

    @State private var logoRotation: Double = 0
    /// Пока экран перекрыт другими, таймер не перерисовывает его впустую.
    @State private var isVisible = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if auth.isSignedIn {
                TabViewContent()
            } else if let email = auth.pendingEmail {
                EmailVerificationView(email: email)
                    .environmentObject(auth)
            } else {
                NavigationView {
                    ZStack {
                        NavigationLink(isActive: $auth.nextAuth) {
                            AuthView(backButton: $auth.nextAuth, viewState: viewState)
                                .environmentObject(auth)
                        } label: {
                            EmptyView()
                        }

                        BlurredWallpaperBackground()

                        logo

                        VStack(spacing: 15) {
                            Spacer()
                            openAuthButton(mode: .auth, model: .auth, state: .activeBlack)
                            openAuthButton(mode: .reg, model: .reg, state: .activeWhite)
                        }
                    }
                    .onAppear { isVisible = true }
                    .onDisappear { isVisible = false }
                }
            }
        }
        .onAppear(perform: auth.checkHaveUser)
    }

    private var logo: some View {
        VStack(spacing: 0) {
            Image(AppImage.brandLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .background(Color.appBlack)
                .cornerRadius(100)
                .rotationEffect(.degrees(logoRotation))
                .onReceive(timer) { _ in
                    guard isVisible else { return }
                    logoRotation += 30
                }
                .animation(.easeInOut(duration: 3).delay(1), value: logoRotation)

            Text(verbatim: "Montblanc")
                .font(.babylonica(size: 54))
            Text(SwiftGen.Welcome.subtitle)
                .font(.system(size: 24, design: .serif))
        }
    }

    private func openAuthButton(mode: AuthState, model: ButtonModel, state: ButtonState) -> some View {
        Button {
            viewState = mode
            auth.openAuthScreen()
        } label: {
            ButtonView(model: model, state: state)
        }
    }
}

struct LoadPreview_Previews: PreviewProvider {
    static var previews: some View {
        LoadPreview()
            .previewThemes()
    }
}
