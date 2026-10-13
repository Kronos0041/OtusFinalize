import SwiftUI

/// Первый шаг: email. После проверки открывается ввод пароля или создание нового.
/// Ниже — вход через Apple, Facebook и Google (пока заглушки).
struct EmailEntryView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        AuthStepLayout(
            title: SwiftGen.Auth.Email.title,
            subtitle: Text(SwiftGen.Auth.Email.subtitle)
        ) {
            AuthTextField(
                placeholder: SwiftGen.Common.email,
                text: Binding(get: { authViewModel.email }, set: authViewModel.updateEmail),
                contentType: .emailAddress,
                keyboard: .emailAddress,
                onSubmit: authViewModel.continueWithEmail
            )

            Button(action: authViewModel.continueWithEmail) {
                ButtonView(
                    model: .continueAction,
                    state: authViewModel.canContinueWithEmail || authViewModel.isSubmitting ? .activeBlack : .disabled,
                    isLoading: authViewModel.isSubmitting
                )
            }
            .disabled(!authViewModel.canContinueWithEmail)

            divider
                .padding(.vertical, 8)

            ForEach(SocialSignInProvider.allCases, id: \.self) { provider in
                SocialSignInButton(provider: provider) { authViewModel.signIn(with: provider) }
            }
        } bottom: {
            EmptyView()
        }
        .toast(authViewModel.toast, dismiss: authViewModel.dismissToast)
    }

    private var divider: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color.appBlack.opacity(0.2)).frame(height: 1)
            Text(SwiftGen.Auth.or)
                .font(.system(size: 15))
                .foregroundStyle(Color.appBlack.opacity(0.6))
            Rectangle().fill(Color.appBlack.opacity(0.2)).frame(height: 1)
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
struct EmailEntryView_Previews: PreviewProvider {
    static var previews: some View {
        EmailEntryView()
            .environment(AppDIContainer.mock(authSession: .signedOut).makeAuthViewModel())
            .previewThemes()
    }
}
#endif
