import SwiftUI

/// Общий каркас шагов авторизации: размытый фон, «назад», заголовок, подзаголовок,
/// содержимое и основная кнопка, прижатая к низу (над клавиатурой).
struct AuthStepLayout<Content: View, Bottom: View>: View {
    let title: String
    var subtitle: Text?
    var onBack: (() -> Void)?
    @ViewBuilder var content: () -> Content
    @ViewBuilder var bottom: () -> Bottom

    var body: some View {
        ZStack {
            BlurredWallpaperBackground()

            VStack(alignment: .leading, spacing: 0) {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.appBlack)
                            .frame(width: 40, height: 40)
                            .background(Color.appWhite, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(SwiftGen.Common.back)
                    .padding(.bottom, 20)
                }

                Text(title)
                    .font(.system(size: 32, design: .serif))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                if let subtitle {
                    subtitle
                        .font(.system(size: 16))
                        .foregroundStyle(Color.appBlack.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)
                }

                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
                .padding(.top, 24)

                Spacer(minLength: 16)

                bottom()
            }
            .foregroundStyle(Color.appBlack)
            .padding(.horizontal, ComponentConstants.Layout.sideInset / 2)
            .padding(.top, onBack == nil ? 48 : 8)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
