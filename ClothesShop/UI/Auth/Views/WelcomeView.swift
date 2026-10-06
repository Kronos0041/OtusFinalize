//
//  WelcomeView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Стартовый экран: логотип и выбор «вход / регистрация».
/// Если пользователь уже авторизован, сразу открывается `MainTabView`.
struct WelcomeView: View {
    @Bindable private var auth: AuthViewModel
    private let container: AppDIContainer

    @State private var logoRotation: Double = 0
    /// Пока экран перекрыт другими, таймер не перерисовывает его впустую.
    @State private var isVisible = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(viewModel: AuthViewModel, container: AppDIContainer) {
        _auth = Bindable(viewModel)
        self.container = container
    }

    var body: some View {
        Group {
            if auth.isSignedIn {
                MainTabView(container: container)
            } else if let email = auth.pendingEmail {
                EmailVerificationView(email: email)
                    .environment(auth)
            } else {
                NavigationStack(path: $auth.path) {
                    ZStack {
                        BlurredWallpaperBackground()

                        logo

                        VStack(spacing: 15) {
                            Spacer()
                            openAuthButton(mode: .signIn, model: .signIn, state: .activeBlack)
                            openAuthButton(mode: .registration, model: .registration, state: .activeWhite)
                        }
                    }
                    .onAppear { isVisible = true }
                    .onDisappear { isVisible = false }
                    .navigationDestination(for: AuthRoute.self) { route in
                        switch route {
                        case .form(let mode):
                            AuthView(mode: mode)
                        }
                    }
                }
                .environment(auth)
            }
        }
        .onAppear(perform: auth.observeSession)
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

    private func openAuthButton(mode: AuthMode, model: ButtonModel, state: ButtonState) -> some View {
        Button {
            auth.openAuthForm(mode: mode)
        } label: {
            ButtonView(model: model, state: state)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: AppDIContainer.shared.makeAuthViewModel(),
                    container: .shared)
            .previewThemes()
    }
}
