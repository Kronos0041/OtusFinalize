import SwiftUI

/// Поле ввода на экранах авторизации: белая плашка в стиле приложения.
/// Для пароля (`isSecure`) справа кнопка-«глаз», которая показывает введённый текст.
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var contentType: UITextContentType?
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .continue
    var onSubmit: () -> Void = {}

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isSecure && !isRevealed {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textContentType(contentType)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .onSubmit(onSubmit)

            if isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye" : "eye.slash")
                        .foregroundStyle(Color.appBlack)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed ? SwiftGen.Auth.Password.hide : SwiftGen.Auth.Password.show)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: ComponentConstants.Layout.buttonHeight)
        .background(Color.appWhite, in: RoundedRectangle(cornerRadius: ComponentConstants.Button.cornerRadius))
    }
}
