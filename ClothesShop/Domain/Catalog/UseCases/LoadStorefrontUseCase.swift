/// Стартовая загрузка магазина: каталог, корзина и настройки читаются параллельно.
/// Ошибка одного запроса не отменяет остальные — каждый результат возвращается отдельно.
struct LoadStorefrontUseCase {
    private let getCatalogUseCase: GetCatalogUseCase
    private let getCartUseCase: GetCartUseCase
    private let getStoreSettingsUseCase: GetStoreSettingsUseCase

    init(getCatalogUseCase: GetCatalogUseCase,
         getCartUseCase: GetCartUseCase,
         getStoreSettingsUseCase: GetStoreSettingsUseCase) {
        self.getCatalogUseCase = getCatalogUseCase
        self.getCartUseCase = getCartUseCase
        self.getStoreSettingsUseCase = getStoreSettingsUseCase
    }

    func execute(ownerID: String) async -> StorefrontLoadResult {
        async let catalog = Self.result { try await getCatalogUseCase.execute() }
        async let cart = Self.result { try await getCartUseCase.execute(ownerID: ownerID) }
        async let settings = Self.result { try await getStoreSettingsUseCase.execute() }
        return StorefrontLoadResult(catalog: await catalog,
                                    cart: await cart,
                                    settings: await settings)
    }

    private static func result<Value>(_ operation: () async throws -> Value) async -> Result<Value, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }
}
