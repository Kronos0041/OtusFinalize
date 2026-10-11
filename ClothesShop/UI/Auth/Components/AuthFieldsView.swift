import SwiftUI

struct AuthFieldsView: View {
    let auth: AuthViewModel
    let mode: AuthMode
    let width: CGFloat

    var body: some View {
        VStack(spacing: 15) {
            TextField(SwiftGen.Common.email, text: Binding(get: { auth.email }, set: auth.updateEmail), onEditingChanged: { isEditing in
                auth.emailEditingChanged(isEditing: isEditing)
            })
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            SecureField(SwiftGen.Auth.password, text: Binding(get: { auth.password }, set: auth.updatePassword))
                .textContentType(mode == .registration ? .newPassword : .password)

            if mode == .registration {
                SecureField(SwiftGen.Auth.repeatPassword, text: Binding(get: { auth.repeatPassword }, set: auth.updateRepeatPassword))
                    .textContentType(.newPassword)
            }
        }
        .padding()
        .frame(width: width)
        .background(Color.appWhite)
        .cornerRadius(10)
    }
}

#if DEBUG
struct AuthFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppDIContainer.preview(authSession: .signedOut)
        return Group {
            AuthFieldsView(auth: container.makeAuthViewModel(), mode: .signIn, width: 340)
                .previewLayout(.sizeThatFits)
                .previewThemes("Вход")
            AuthFieldsView(auth: container.makeAuthViewModel(), mode: .registration, width: 340)
                .previewLayout(.sizeThatFits)
                .previewThemes("Регистрация")
        }
    }
}
#endif
