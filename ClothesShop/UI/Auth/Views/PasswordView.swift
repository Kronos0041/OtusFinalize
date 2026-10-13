import SwiftUI

/// Вход: аккаунт с этим email есть, нужен пароль.
struct PasswordView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AuthStepLayout(
            title: SwiftGen.Auth.Password.title,
            subtitle: Text(authViewModel.email).bold(),
            onBack: { dismiss() }
        ) {
            AuthTextField(
                placeholder: SwiftGen.Auth.password,
                text: Binding(get: { authViewModel.password }, set: authViewModel.updatePassword),
                isSecure: true,
                contentType: .password,
                submitLabel: .go,
                onSubmit: authViewModel.signIn
            )

            AuthCapsuleButton(title: SwiftGen.Auth.Password.forgot, action: authViewModel.resetPassword)
                .disabled(authViewModel.isSubmitting)
        } bottom: {
            Button(action: authViewModel.signIn) {
                ButtonView(
                    model: .continueAction,
                    state: authViewModel.canSignIn || authViewModel.isSubmitting ? .activeBlack : .disabled,
                    isLoading: authViewModel.isSubmitting
                )
            }
            .disabled(!authViewModel.canSignIn)
        }
        .toast(authViewModel.toast, dismiss: authViewModel.dismissToast)
    }
}

#if DEBUG
struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PasswordView()
                .environment(AppDIContainer.mock(authSession: .signedOut).makeAuthViewModel())
        }
        .previewThemes()
    }
}
#endif
