import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var accountChange: AccountChange?

    init(viewModel: MainViewModel = MainViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ViewModeView(viewModel.viewMode,
                             emptyTitle: SwiftGen.Common.empty,
                             emptySystemImage: "person.crop.circle",
                             retry: viewModel.loadProfile) { _ in
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
        .onChange(of: scenePhase) { phase in
            if phase == .active { viewModel.loadProfile() }
        }
        .sheet(item: $accountChange, onDismiss: viewModel.resetForm) { change in
            AccountChangeView(change: change, viewModel: viewModel) {
                accountChange = nil
            }
        }
        .alert(SwiftGen.Profile.settings, isPresented: Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
        )) {
            Button(SwiftGen.Common.ok, role: .cancel) { viewModel.successMessage = nil }
        } message: {
            Text(verbatim: viewModel.successMessage ?? "")
        }
    }

    private func open(_ change: AccountChange) {
        viewModel.resetForm()
        accountChange = change
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel(previewProfile: ProfileViewState(email: "alex@example.com")))
            .previewThemes()
    }
}
#endif
