import SwiftUI

struct AppRootView: View {
    private let container: AppDIContainer
    @State private var authViewModel: AuthViewModel

    init(container: AppDIContainer) {
        self.container = container
        _authViewModel = State(initialValue: container.makeAuthViewModel())
    }

    var body: some View {
        WelcomeView(viewModel: authViewModel, container: container)
    }
}
