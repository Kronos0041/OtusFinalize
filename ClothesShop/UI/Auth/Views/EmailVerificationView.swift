import SwiftUI

/// Новый аккаунт уже создан в Firebase Auth, но каталог откроется только после проверки адреса.
struct EmailVerificationView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    let email: String

    var body: some View {
        ZStack {
            BlurredWallpaperBackground()

            VStack(spacing: 20) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 52))

                Text(SwiftGen.Auth.Verification.title)
                    .font(.system(size: 32, design: .serif))
                    .bold()

                Text(SwiftGen.Auth.Verification.instructions(email))
                    .multilineTextAlignment(.center)

                if !authViewModel.verificationMessage.isEmpty {
                    Text(authViewModel.verificationMessage)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                if authViewModel.isSubmitting {
                    ProgressView()
                }

                Button(SwiftGen.Auth.Verification.check, action: authViewModel.refreshEmailVerification)
                    .buttonStyle(.borderedProminent)
                    .disabled(authViewModel.isSubmitting)

                Button(SwiftGen.Auth.Verification.resend, action: authViewModel.resendVerificationEmail)
                    .disabled(authViewModel.isSubmitting)

                Button(SwiftGen.Auth.signOut, action: authViewModel.signOut)
                    .disabled(authViewModel.isSubmitting)
            }
            .padding(24)
        }
    }
}

#if DEBUG
struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        let email = PreviewData.profile.email
        return EmailVerificationView(email: email)
            .environment(
                AppDIContainer.mock(authSession: .awaitingEmailVerification(email)).makeAuthViewModel()
            )
            .previewThemes()
    }
}
#endif
