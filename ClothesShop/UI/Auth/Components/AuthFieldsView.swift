import SwiftUI

struct AuthFieldsView: View {
    let authViewModel: AuthViewModel
    let mode: AuthMode
    let width: CGFloat

    var body: some View {
        VStack(spacing: 15) {
            TextField(SwiftGen.Common.email, text: Binding(get: { authViewModel.email }, set: authViewModel.updateEmail), onEditingChanged: { isEditing in
                authViewModel.emailEditingChanged(isEditing: isEditing)
            })
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            SecureField(SwiftGen.Auth.password, text: Binding(get: { authViewModel.password }, set: authViewModel.updatePassword))
                .textContentType(mode == .registration ? .newPassword : .password)

            if mode == .registration {
                SecureField(SwiftGen.Auth.repeatPassword, text: Binding(get: { authViewModel.repeatPassword }, set: authViewModel.updateRepeatPassword))
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
        let container = AppDIContainer.mock(authSession: .signedOut)
        return Group {
            AuthFieldsView(authViewModel: container.makeAuthViewModel(), mode: .signIn, width: 340)
                .previewLayout(.sizeThatFits)
                .previewThemes("Вход")
            AuthFieldsView(authViewModel: container.makeAuthViewModel(), mode: .registration, width: 340)
                .previewLayout(.sizeThatFits)
                .previewThemes("Регистрация")
        }
    }
}
#endif
