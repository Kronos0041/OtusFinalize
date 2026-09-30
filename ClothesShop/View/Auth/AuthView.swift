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
                Text(viewState == .auth ? LocalizedStringKey("Войти") : LocalizedStringKey("Регистрация"))
                    .font(.system(size: 35, design: .serif))

                VStack(spacing: 10) {
                    errorBanner
                    fields
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

    private var fields: some View {
        VStack(spacing: 15) {
            TextField("Email", text: $auth.email, onEditingChanged: { isEditing in
                auth.emailEditingChanged(isEditing: isEditing)
            })
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            SecureField("Пароль", text: $auth.password)
                .textContentType(viewState == .reg ? .newPassword : .password)

            if viewState == .reg {
                SecureField("Повторите пароль", text: $auth.repeatPassword)
                    .textContentType(.newPassword)
            }
        }
        .padding()
        .frame(width: fieldsWidth)
        .background(Color.appWhite)
        .cornerRadius(10)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(backButton: .constant(false), viewState: .reg)
            .environmentObject(AuthVM())
    }
}

/// Новый аккаунт уже создан в Firebase Auth, но каталог откроется только после проверки адреса.
struct EmailVerificationView: View {
    @EnvironmentObject private var auth: AuthVM
    let email: String

    var body: some View {
        ZStack {
            BlurredWallpaperBackground()

            VStack(spacing: 20) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 52))

                Text("Подтвердите email")
                    .font(.system(size: 32, design: .serif))
                    .bold()

                Text("Мы отправили письмо на \(email). Откройте ссылку в письме, затем вернитесь сюда.")
                    .multilineTextAlignment(.center)

                if !auth.verificationMessage.isEmpty {
                    Text(auth.verificationMessage)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                if auth.isSubmitting {
                    ProgressView()
                }

                Button("Я подтвердил адрес", action: auth.checkEmailVerification)
                    .buttonStyle(.borderedProminent)
                    .disabled(auth.isSubmitting)

                Button("Отправить письмо ещё раз", action: auth.resendVerificationEmail)
                    .disabled(auth.isSubmitting)

                Button("Выйти из аккаунта", action: auth.leaveVerificationScreen)
                    .disabled(auth.isSubmitting)
            }
            .padding(24)
        }
    }
}
