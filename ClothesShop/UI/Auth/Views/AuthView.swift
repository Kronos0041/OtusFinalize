//
//  AuthView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Экран входа / регистрации. Вся логика — в `AuthViewModel`, здесь только разметка.
struct AuthView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    let mode: AuthMode

    private var fieldsWidth: CGFloat { getWidth() - ComponentConstants.Layout.sideInset }

    var body: some View {
        ZStack {
            BlurredWallpaperBackground()

            VStack(spacing: 15) {
                Text(mode == .signIn ? SwiftGen.Auth.signIn : SwiftGen.Auth.signUp)
                    .font(.system(size: 35, design: .serif))

                VStack(spacing: 10) {
                    errorBanner
                    AuthFieldsView(authViewModel: authViewModel, mode: mode, width: fieldsWidth)
                }

                Button {
                    authViewModel.submit(mode: mode)
                } label: {
                    ButtonView(model: mode == .signIn ? .signIn : .registration, state: .activeBlack)
                }
                .disabled(authViewModel.isSubmitting)

                if authViewModel.isSubmitting {
                    ProgressView()
                }

                Button {
                    dismiss()
                } label: {
                    ButtonView(model: .back, state: .activeWhite)
                }
            }
        }
        .animation(.easeInOut(duration: 1), value: authViewModel.banner.isVisible)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Вложенные view

    private var errorBanner: some View {
        Group {
            if authViewModel.banner.isVisible {
                Text(authViewModel.banner.message)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: fieldsWidth)
                    .background(Color.appRed.opacity(0.6))
                    .cornerRadius(10)
                    .onTapGesture { authViewModel.dismissBanner() }
            }
        }
    }
}

#if DEBUG
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthView(mode: .signIn)
                .previewThemes("Вход")
            AuthView(mode: .registration)
                .previewThemes("Регистрация")
        }
        .environment(AppDIContainer.mock(authSession: .signedOut).makeAuthViewModel())
    }
}
#endif
