/// Стартовая загрузка магазина: каталог, корзина и настройки читаются параллельно.
/// Ошибка одного запроса не отменяет остальные — каждый результат возвращается отдельно.
struct GetShopDataUseCase {
    private let getCatalogUseCase: GetCatalogUseCase
    private let getCartUseCase: GetCartUseCase
    private let getStoreSettingsUseCase: GetStoreSettingsUseCase

    init(
        getCatalogUseCase: GetCatalogUseCase,
        getCartUseCase: GetCartUseCase,
        getStoreSettingsUseCase: GetStoreSettingsUseCase
    ) {
        self.getCatalogUseCase = getCatalogUseCase
        self.getCartUseCase = getCartUseCase
        self.getStoreSettingsUseCase = getStoreSettingsUseCase
    }

    func getShopData(ownerID: String) async -> ShopData {
        async let catalog = Self.result { try await getCatalogUseCase.getCatalog() }
        async let cart = Self.result { try await getCartUseCase.getCart(ownerID: ownerID) }
        async let settings = Self.result { try await getStoreSettingsUseCase.getStoreSettings() }
        return ShopData(
            catalog: await catalog,
            cart: await cart,
            settings: await settings
        )
    }

    private static func result<Value>(_ operation: () async throws -> Value) async -> Result<Value, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }
}
