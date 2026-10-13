import SwiftUI

/// Аккаунт создан, ждём подтверждения почты по ссылке из письма.
/// «Назад» выходит из аккаунта и возвращает к вводу email.
struct EmailVerificationView: View {
    @State private var viewModel: EmailVerificationViewModel

    init(viewModel: @autoclosure () -> EmailVerificationViewModel) {
        _viewModel = State(wrappedValue: viewModel())
    }

    var body: some View {
        AuthStepLayout(
            title: SwiftGen.Auth.Verification.title,
            subtitle: Text(SwiftGen.Auth.Verification.instructions(viewModel.email)),
            onBack: viewModel.signOut
        ) {
            AuthCapsuleButton(title: SwiftGen.Auth.Verification.resend, action: viewModel.resendVerificationEmail)
                .disabled(viewModel.isSubmitting)
        } bottom: {
            VStack(alignment: .leading, spacing: 20) {
                OpenMailButton(email: viewModel.email)

                Button(action: viewModel.refreshEmailVerification) {
                    ButtonView(model: .emailConfirmed, state: .activeBlack, isLoading: viewModel.isSubmitting)
                }
                .disabled(viewModel.isSubmitting)
            }
        }
        .toast(viewModel.toast, dismiss: viewModel.dismissToast)
    }
}

#if DEBUG
struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        let email = "alex@example.com"
        EmailVerificationView(viewModel: AppDIContainer.mock(authSession: .awaitingEmailVerification(email))
            .makeEmailVerificationViewModel(email: email, onVerified: {}))
            .previewThemes()
    }
}
#endif
