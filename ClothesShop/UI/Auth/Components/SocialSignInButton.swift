import SwiftUI

/// Кнопка входа через Apple, Facebook или Google в стиле белых кнопок приложения.
struct SocialSignInButton: View {
    let provider: SocialSignInProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                logo
                    .frame(width: 22, height: 22)
                    .accessibilityHidden(true)
                Text(SwiftGen.Auth.Social.continueWith(provider.name))
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(Color.appBlack)
            .frame(maxWidth: .infinity)
            .frame(height: ComponentConstants.Layout.buttonHeight)
            .background(Color.appWhite, in: RoundedRectangle(cornerRadius: ComponentConstants.Button.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    /// Apple — системный символ, Facebook и Google — SVG из `Assets.xcassets/AppImage`.
    private var logo: some View {
        Group {
            switch provider {
            case .apple: Image(systemName: "apple.logo").resizable()
            case .facebook: Image(AppImage.facebookLogo).resizable()
            case .google: Image(AppImage.googleLogo).resizable()
            }
        }
        .scaledToFit()
    }
}

#if DEBUG
struct SocialSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(SocialSignInProvider.allCases, id: \.self) { provider in
                SocialSignInButton(provider: provider) {}
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .previewLayout(.sizeThatFits)
    }
}
#endif
