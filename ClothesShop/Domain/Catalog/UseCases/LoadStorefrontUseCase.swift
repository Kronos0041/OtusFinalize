import Foundation

struct LoadStorefrontUseCase {
    private let catalogRepository: CatalogRepositoryProtocol
    private let cartRepository: CartRepositoryProtocol
    private let settingsRepository: StoreSettingsRepositoryProtocol

    init(catalogRepository: CatalogRepositoryProtocol,
         cartRepository: CartRepositoryProtocol,
         settingsRepository: StoreSettingsRepositoryProtocol) {
        self.catalogRepository = catalogRepository
        self.cartRepository = cartRepository
        self.settingsRepository = settingsRepository
    }

    func execute(ownerID: String, completion: @escaping (StorefrontLoadResult) -> Void) {
        let group = DispatchGroup()
        var catalog: Result<Catalog, Error>?
        var cart: Result<[CartItem], Error>?
        var settings: Result<StoreSettings, Error>?

        group.enter()
        catalogRepository.fetchCatalog { catalog = $0; group.leave() }
        group.enter()
        cartRepository.fetchCart(ownerID: ownerID) { cart = $0; group.leave() }
        group.enter()
        settingsRepository.fetchSettings { settings = $0; group.leave() }

        group.notify(queue: .main) {
            let missing = NSError(domain: "ClothesShop.Storefront", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: "Получен неполный ответ."])
            completion(StorefrontLoadResult(
                catalog: catalog ?? .failure(missing),
                cart: cart ?? .failure(missing),
                settings: settings ?? .failure(missing)
            ))
        }
    }
}
