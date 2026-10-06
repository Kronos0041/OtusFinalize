import SwiftUI

struct ProfileContentView: View {
    let viewModel: ProfileViewModel
    let selectChange: (AccountChangeType) -> Void

    var body: some View {
        List {
            Section(SwiftGen.Profile.title) {
                UserProfileCell()
                    .environment(viewModel)
            }

            Section(SwiftGen.Profile.settings) {
                Button { selectChange(.password) } label: {
                    Label(SwiftGen.Profile.changePassword, systemImage: "lock")
                }
                Button { selectChange(.email) } label: {
                    Label(SwiftGen.Profile.changeEmail, systemImage: "envelope")
                }
            }
            .disabled(viewModel.isSubmitting || viewModel.isRefreshing)

            Section {
                Button(action: viewModel.loadProfile) {
                    HStack {
                        Text(SwiftGen.Profile.refresh)
                        Spacer()
                        if viewModel.isRefreshing { ProgressView() }
                    }
                }
                .disabled(viewModel.isRefreshing || viewModel.isSubmitting)
                if let error = viewModel.profileError {
                    Text(verbatim: error)
                        .font(.footnote)
                        .foregroundColor(.appRed)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#if DEBUG
struct ProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppDIContainer.shared.makeProfileViewModel()
        viewModel.applyPreview(profile: UserProfile(email: "alex@example.com"))
        return ProfileContentView(viewModel: viewModel, selectChange: { _ in })
            .previewThemes()
    }
}
#endif
