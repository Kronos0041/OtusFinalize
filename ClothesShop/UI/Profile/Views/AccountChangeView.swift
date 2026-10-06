import SwiftUI

struct AccountChangeView: View {
    let change: AccountChangeType
    @ObservedObject var viewModel: ProfileViewModel
    let close: () -> Void

    private var title: String {
        change == .password ? SwiftGen.Profile.changePassword : SwiftGen.Profile.changeEmail
    }

    var body: some View {
        NavigationView {
            Form {
                Section(SwiftGen.Profile.currentPassword) {
                    SecureField(SwiftGen.Profile.currentPassword, text: $viewModel.currentPassword)
                        .textContentType(.password)
                }

                if change == .password {
                    Section(SwiftGen.Profile.newPassword) {
                        SecureField(SwiftGen.Profile.newPassword, text: $viewModel.newPassword)
                            .textContentType(.newPassword)
                        SecureField(SwiftGen.Profile.repeatNewPassword, text: $viewModel.repeatPassword)
                            .textContentType(.newPassword)
                        Text(SwiftGen.Profile.passwordHint)
                            .font(.footnote)
                            .foregroundColor(.appGray)
                    }
                } else {
                    Section {
                        TextField(SwiftGen.Profile.newEmail, text: $viewModel.newEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } header: {
                        Text(SwiftGen.Profile.newEmail)
                    } footer: {
                        Text(SwiftGen.Profile.emailHint)
                    }
                }

                if let error = viewModel.formError {
                    Section {
                        Text(verbatim: error)
                            .foregroundColor(.appRed)
                    }
                }

                Section {
                    Button {
                        viewModel.submit(change, completion: close)
                    } label: {
                        HStack {
                            Text(change == .password ? SwiftGen.Profile.savePassword : SwiftGen.Profile.sendConfirmation)
                            Spacer()
                            if viewModel.isSubmitting { ProgressView() }
                        }
                    }
                }
            }
            .disabled(viewModel.isSubmitting || viewModel.isRefreshing)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(SwiftGen.Common.cancel, action: close)
                        .disabled(viewModel.isSubmitting)
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }
}


#if DEBUG
struct AccountChangeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppDIContainer.shared.makeProfileViewModel()
        viewModel.applyPreview(profile: UserProfile(email: "alex@example.com"))
        return Group {
            AccountChangeView(change: .password, viewModel: viewModel, close: {})
            AccountChangeView(change: .email, viewModel: viewModel, close: {})
        }
        .previewThemes()
    }
}
#endif
