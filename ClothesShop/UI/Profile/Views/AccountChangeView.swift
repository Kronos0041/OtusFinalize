import SwiftUI

struct AccountChangeView: View {
    let change: AccountChangeType
    let viewModel: ProfileViewModel
    let close: () -> Void

    private var title: String {
        change == .password ? SwiftGen.Profile.changePassword : SwiftGen.Profile.changeEmail
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(SwiftGen.Profile.currentPassword) {
                    SecureField(SwiftGen.Profile.currentPassword, text: Binding(
                        get: { viewModel.currentPassword },
                        set: viewModel.updateCurrentPassword
                    ))
                        .textContentType(.password)
                }

                if change == .password {
                    Section(SwiftGen.Profile.newPassword) {
                        SecureField(SwiftGen.Profile.newPassword, text: Binding(
                            get: { viewModel.newPassword },
                            set: viewModel.updateNewPassword
                        ))
                            .textContentType(.newPassword)
                        SecureField(SwiftGen.Profile.repeatNewPassword, text: Binding(
                            get: { viewModel.repeatPassword },
                            set: viewModel.updateRepeatPassword
                        ))
                            .textContentType(.newPassword)
                        Text(SwiftGen.Profile.passwordHint)
                            .font(.footnote)
                            .foregroundColor(.appGray)
                    }
                } else {
                    Section {
                        TextField(SwiftGen.Profile.newEmail, text: Binding(
                            get: { viewModel.newEmail },
                            set: viewModel.updateNewEmail
                        ))
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
                        Task { if await viewModel.submit(change) { close() } }
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
        let viewModel = AppDIContainer.mock().makeLoadedProfileViewModel()
        return Group {
            AccountChangeView(change: .password, viewModel: viewModel, close: {})
                .previewThemes("Смена пароля")
            AccountChangeView(change: .email, viewModel: viewModel, close: {})
                .previewThemes("Смена email")
        }
    }
}
#endif
