import SwiftUI

struct AuthFieldsView: View {
    @ObservedObject var auth: AuthVM
    let mode: AuthState
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
                .textContentType(mode == .reg ? .newPassword : .password)

            if mode == .reg {
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
            AuthFieldsView(auth: AuthVM(), mode: .auth, width: 340)
            AuthFieldsView(auth: AuthVM(), mode: .reg, width: 340)
        }
        .previewLayout(.sizeThatFits)
        .previewThemes()
    }
}
