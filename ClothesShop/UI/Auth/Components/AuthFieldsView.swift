import SwiftUI

struct AuthFieldsView: View {
    @Bindable var auth: AuthViewModel
    let mode: AuthMode
    let width: CGFloat

    var body: some View {
        VStack(spacing: 15) {
            TextField(SwiftGen.Common.email, text: $auth.email, onEditingChanged: { isEditing in
                auth.emailEditingChanged(isEditing: isEditing)
            })
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            SecureField(SwiftGen.Auth.password, text: $auth.password)
                .textContentType(mode == .registration ? .newPassword : .password)

            if mode == .registration {
                SecureField(SwiftGen.Auth.repeatPassword, text: $auth.repeatPassword)
                    .textContentType(.newPassword)
            }
        }
        .padding()
        .frame(width: width)
        .background(Color.appWhite)
        .cornerRadius(10)
    }
}

struct AuthFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthFieldsView(auth: AppDIContainer.shared.makeAuthViewModel(), mode: .signIn, width: 340)
                .previewLayout(.sizeThatFits)
                .previewThemes("Вход")
            AuthFieldsView(auth: AppDIContainer.shared.makeAuthViewModel(), mode: .registration, width: 340)
                .previewLayout(.sizeThatFits)
                .previewThemes("Регистрация")
        }
    }
}
