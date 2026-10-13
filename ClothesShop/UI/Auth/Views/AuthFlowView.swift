//
//  AuthFlowView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Выбор экрана по сессии: каталог, подтверждение почты или вход.
///
/// Каждая ветка владеет своей ViewModel через `@State`. При смене сессии ветка исчезает, и её ViewModel
/// уничтожается вместе с введёнными данными: после выхода вход открывается с чистого листа.
///
/// У каждой ветки свой `NavigationStack`: SwiftUI держит последний снятый стек вместе с его окружением
/// (а значит, и с ViewModel), пока на экране не появится новый стек.
struct AuthFlowView: View {
    let sessionViewModel: SessionViewModel
    let container: AppDIContainer

    var body: some View {
        switch sessionViewModel.session {
        case .verified:
            MainTabView(container: container)
        case .awaitingEmailVerification(let email):
            NavigationStack {
                EmailVerificationView(viewModel: container.makeEmailVerificationViewModel(
                    email: email,
                    onVerified: sessionViewModel.markEmailVerified
                ))
            }
        case .signedOut:
            SignInFlowView(viewModel: container.makeAuthViewModel())
        }
    }
}

/// Стек входа: email → пароль или создание пароля. Владеет `AuthViewModel` на время показа.
private struct SignInFlowView: View {
    @State private var authViewModel: AuthViewModel

    /// SwiftUI сохраняет ViewModel из первого создания экрана, повторные экземпляры отбрасываются.
    init(viewModel: @autoclosure () -> AuthViewModel) {
        _authViewModel = State(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack(path: Binding(get: { authViewModel.path }, set: authViewModel.updatePath)) {
            EmailEntryView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .password: PasswordView()
                    case .createPassword: CreatePasswordView()
                    }
                }
        }
        .environment(authViewModel)
    }
}

#if DEBUG
struct AuthFlowView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppDIContainer.mock(authSession: .signedOut)
        return AuthFlowView(sessionViewModel: container.makeSessionViewModel(), container: container)
            .previewThemes()
    }
}
#endif
