import SwiftUI

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

                Button(SwiftGen.Auth.Verification.check, action: auth.checkEmailVerification)
                    .buttonStyle(.borderedProminent)
                    .disabled(auth.isSubmitting)

                Button(SwiftGen.Auth.Verification.resend, action: auth.resendVerificationEmail)
                    .disabled(auth.isSubmitting)

                Button(SwiftGen.Auth.signOut, action: auth.leaveVerificationScreen)
                    .disabled(auth.isSubmitting)
            }
            .padding(24)
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(email: "alex@example.com")
            .environmentObject(AuthVM())
            .previewThemes()
    }
}
