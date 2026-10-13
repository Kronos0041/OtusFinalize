import SwiftUI

/// Корень приложения: экраны по состоянию сессии, поверх них — заставка, которая убирает себя сама.
struct AppRootView: View {
    private let container: AppDIContainer
    @State private var sessionViewModel: SessionViewModel

    init(container: AppDIContainer) {
        self.container = container
        _sessionViewModel = State(initialValue: container.makeSessionViewModel())
    }

    var body: some View {
        AuthFlowView(sessionViewModel: sessionViewModel, container: container)
            .overlay { SplashView() }
            // Подписка на сессию стартует вместе с заставкой: к её концу экран под ней уже выбран.
            .onAppear(perform: sessionViewModel.observeSession)
    }
}
