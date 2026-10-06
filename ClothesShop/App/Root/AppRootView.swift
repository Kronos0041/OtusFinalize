import SwiftUI

struct AppRootView: View {
    private let container: AppDIContainer
    @StateObject private var authViewModel: AuthViewModel

    init(container: AppDIContainer) {
        self.container = container
        _authViewModel = StateObject(wrappedValue: container.makeAuthViewModel())
    }

    var body: some View {
        WelcomeView(viewModel: authViewModel, container: container)
    }
}
