import SwiftUI

struct ProfileView: View {
    private let viewModel: ProfileViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var accountChange: AccountChangeType?

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            ViewModeView(
                viewModel.mode,
                emptyTitle: SwiftGen.Common.empty,
                emptySystemImage: "person.crop.circle",
                retry: viewModel.loadProfile
            ) { _ in
                    ProfileContentView(viewModel: viewModel, selectChange: open)
                }

                VStack(spacing: 8) {
                    if let error = viewModel.signOutError {
                        Text(verbatim: error)
                            .font(.footnote)
                            .foregroundColor(.appRed)
                    }
                    Button(SwiftGen.Profile.signOut, role: .destructive, action: viewModel.signOut)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.appWhite)
                        .cornerRadius(12)
                        .disabled(viewModel.isSubmitting)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(SwiftGen.Profile.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: viewModel.loadProfile)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.loadProfile() }
        }
        .sheet(item: $accountChange, onDismiss: viewModel.resetForm) { change in
            AccountChangeView(change: change, viewModel: viewModel) {
                accountChange = nil
            }
        }
        .alert(SwiftGen.Profile.settings, isPresented: Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.dismissSuccessMessage() } }
        )) {
            Button(SwiftGen.Common.ok, role: .cancel, action: viewModel.dismissSuccessMessage)
        } message: {
            Text(verbatim: viewModel.successMessage ?? "")
        }
    }

    private func open(_ change: AccountChangeType) {
        viewModel.resetForm()
        accountChange = change
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView(viewModel: AppDIContainer.mock().makeProfileViewModel())
                .previewThemes("Профиль")
            ProfileView(viewModel: AppDIContainer.mock(isConnected: false).makeProfileViewModel())
                .previewThemes("Нет сети")
        }
    }
}
#endif
