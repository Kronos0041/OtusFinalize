
import Combine
import Foundation

final class MainTabViewModel: ObservableObject {
    @Published private(set) var state: MainTabViewState = .idle

    let catalog: CatalogViewModel
    let cart: CartViewModel

    private let loadStorefrontUseCase: LoadStorefrontUseCase
    private let authRepository: AuthRepositoryProtocol
    private let connectivityUseCase: ObserveConnectivityUseCase
    private var didStartInitialLoad = false
    private var observation: ObservationToken?

    init(catalog: CatalogViewModel, cart: CartViewModel,
         loadStorefrontUseCase: LoadStorefrontUseCase,
         authRepository: AuthRepositoryProtocol,
         connectivityUseCase: ObserveConnectivityUseCase) {
        self.catalog = catalog; self.cart = cart
        self.loadStorefrontUseCase = loadStorefrontUseCase
        self.authRepository = authRepository
        self.connectivityUseCase = connectivityUseCase
        observation = connectivityUseCase.execute { [weak self] connected in
            if connected { self?.loadIfNeeded() }
        }
    }

    func loadIfNeeded() {
        guard !didStartInitialLoad, state != .loading,
              let ownerID = authRepository.currentUserID else { return }
        guard connectivityUseCase.isConnected else {
            let error = ConnectivityError.offline
            catalog.applyCatalog(.failure(error)); cart.applySettings(.failure(error)); return
        }
        didStartInitialLoad = true; state = .loading
        loadStorefrontUseCase.execute(ownerID: ownerID) { [weak self] result in
            guard let self else { return }
            self.state = .loaded
            if case .failure = result.catalog { self.didStartInitialLoad = false }
            if case .failure = result.cart { self.didStartInitialLoad = false }
            if case .failure = result.settings { self.didStartInitialLoad = false }
            self.catalog.applyCatalog(result.catalog)
            switch (result.catalog, result.settings) {
            case (.success, .success):
                guard self.cart.applySettings(result.settings) else { return }
                self.cart.apply(result.cart, catalog: self.catalog.sections.first?.products ?? [])
            case (.failure(let error), _): self.cart.apply(.failure(error), catalog: [])
            case (_, .failure): _ = self.cart.applySettings(result.settings)
            }
        }
    }
}
