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
    private let authViewModel: AuthViewModel
    private let container: AppDIContainer

    @State private var logoRotation: Double = 0
    /// Пока экран перекрыт другими, таймер не перерисовывает его впустую.
    @State private var isVisible = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(viewModel: AuthViewModel, container: AppDIContainer) {
        authViewModel = viewModel
        self.container = container
    }

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainTabView(container: container)
            } else if let email = authViewModel.pendingEmail {
                EmailVerificationView(email: email)
                    .environment(authViewModel)
            } else {
                NavigationStack(path: Binding(get: { authViewModel.path }, set: authViewModel.updatePath)) {
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
                .environment(authViewModel)
            }
        }
        .onAppear(perform: authViewModel.observeSession)
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
            authViewModel.openAuthForm(mode: mode)
        } label: {
            ButtonView(model: model, state: state)
        }
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppDIContainer.mock(authSession: .signedOut)
        return WelcomeView(viewModel: container.makeAuthViewModel(), container: container)
            .previewThemes()
    }
}
#endif
