import SwiftUI

/// Регистрация: аккаунта с этим email нет, нужно придумать пароль.
struct CreatePasswordView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AuthStepLayout(
            title: SwiftGen.Auth.CreatePassword.title,
            subtitle: Text(SwiftGen.Auth.CreatePassword.subtitle),
            onBack: { dismiss() }
        ) {
            AuthTextField(
                placeholder: SwiftGen.Auth.password,
                text: Binding(get: { authViewModel.password }, set: authViewModel.updatePassword),
                isSecure: true,
                contentType: .newPassword,
                submitLabel: .next
            )
            AuthTextField(
                placeholder: SwiftGen.Auth.repeatPassword,
                text: Binding(get: { authViewModel.repeatPassword }, set: authViewModel.updateRepeatPassword),
                isSecure: true,
                contentType: .newPassword,
                submitLabel: .go,
                onSubmit: authViewModel.register
            )
        } bottom: {
            Button(action: authViewModel.register) {
                ButtonView(
                    model: .continueAction,
                    state: authViewModel.canRegister || authViewModel.isSubmitting ? .activeBlack : .disabled,
                    isLoading: authViewModel.isSubmitting
                )
            }
            .disabled(!authViewModel.canRegister)
        }
        .toast(authViewModel.toast, dismiss: authViewModel.dismissToast)
    }
}

#if DEBUG
struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreatePasswordView()
                .environment(AppDIContainer.mock(authSession: .signedOut).makeAuthViewModel())
        }
        .previewThemes()
    }
}
#endif
