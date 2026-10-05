//
//  AuthView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

enum AuthState {
    case auth
    case reg
}

/// Экран входа / регистрации. Вся логика — в `AuthVM`, здесь только разметка.
struct AuthView: View {
    @EnvironmentObject private var auth: AuthVM
    @Binding var backButton: Bool
    let viewState: AuthState

    private var fieldsWidth: CGFloat { getWidth() - AppLayout.sideInset }

    var body: some View {
        ZStack {
            BlurredWallpaperBackground()

            VStack(spacing: 15) {
                Text(viewState == .auth ? SwiftGen.Auth.signIn : SwiftGen.Auth.signUp)
                    .font(.system(size: 35, design: .serif))

                VStack(spacing: 10) {
                    errorBanner
                    AuthFieldsView(auth: auth, mode: viewState, width: fieldsWidth)
                }

                Button {
                    auth.submit(mode: viewState)
                } label: {
                    ButtonView(model: viewState == .auth ? .auth : .reg, state: .activeBlack)
                }
                .disabled(auth.isSubmitting)

                if auth.isSubmitting {
                    ProgressView()
                }

                Button {
                    backButton.toggle()
                } label: {
                    ButtonView(model: .back, state: .activeWhite)
                }
            }
        }
        .animation(.easeInOut(duration: 1), value: auth.banner.isVisible)
        .navigationBarHidden(true)
    }

    // MARK: - Subviews

    private var errorBanner: some View {
        Group {
            if auth.banner.isVisible {
                Text(auth.banner.message)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: fieldsWidth)
                    .background(Color.appRed.opacity(0.6))
                    .cornerRadius(10)
                    .onTapGesture { auth.banner.isVisible = false }
            }
        }
    }
}

struct AuthViewReg_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(backButton: .constant(false), viewState: .reg)
            .environmentObject(AuthVM())
            .previewThemes()
    }
}

struct AuthViewAuth_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(backButton: .constant(false), viewState: .auth)
            .environmentObject(AuthVM())
            .previewThemes()
    }
}
