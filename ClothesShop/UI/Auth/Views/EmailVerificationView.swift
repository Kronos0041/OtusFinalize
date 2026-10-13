import SwiftUI

/// Новый аккаунт уже создан в Firebase Auth, но каталог откроется только после проверки адреса.
struct EmailVerificationView: View {
    @Environment(AuthViewModel.self) private var auth
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

                if !auth.verificationMessage.isEmpty {
                    Text(auth.verificationMessage)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                if auth.isSubmitting {
                    ProgressView()
                }

                Button(SwiftGen.Auth.Verification.check, action: auth.refreshEmailVerification)
                    .buttonStyle(.borderedProminent)
                    .disabled(auth.isSubmitting)

                Button(SwiftGen.Auth.Verification.resend, action: auth.resendVerificationEmail)
                    .disabled(auth.isSubmitting)

                Button(SwiftGen.Auth.signOut, action: auth.signOut)
                    .disabled(auth.isSubmitting)
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
