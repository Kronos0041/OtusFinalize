import Foundation
import Observation

@MainActor
@Observable
final class CartViewModel {
    private(set) var items: [CartItemViewModel] = []
    private(set) var mode: ViewMode<[CartItemViewModel]> = .loading
    private(set) var errorMessage: String?
    private(set) var isLoaded = false
    private(set) var maximumQuantity = StoreSettings.default.maximumCartItemQuantity

    /// Количество единиц товара для бейджа вкладки.
    var count: Int { items.reduce(0) { $0 + $1.quantity } }

    /// Сумма корзины по актуальным ценам каталога.
    var total: Int { items.reduce(0) { $0 + $1.product.price * $1.quantity } }

    private let ownerID: String?
    private let cartUseCases: CartUseCases
    private let getSettingsUseCase: GetStoreSettingsUseCase

    @ObservationIgnored private var catalogProducts: [CatalogItemViewModel] = []
    @ObservationIgnored private var pendingItemIDs: Set<String> = []
    @ObservationIgnored private var hasLoadedSettings = false
    #if DEBUG
    @ObservationIgnored private var isPreview = false
    #endif

    init(ownerID: String?,
         cartUseCases: CartUseCases,
         getSettingsUseCase: GetStoreSettingsUseCase) {
        self.ownerID = ownerID
        self.cartUseCases = cartUseCases
        self.getSettingsUseCase = getSettingsUseCase
        #if DEBUG
        if ownerID == nil {
            isPreview = true
            isLoaded = true
            hasLoadedSettings = true
            mode = .empty
        }
        #endif
    }

    // MARK: - Данные

    /// Актуальные товары каталога: из них берутся названия и цены позиций.
    func updateCatalog(_ products: [CatalogItemViewModel]) {
        catalogProducts = products
        let byID = Dictionary(products.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
        items = items.map { item in
            var result = item
            result.product = byID[item.product.id] ?? item.product
            return result
        }
        if !items.isEmpty { updateMode() }
    }

    @discardableResult
    func applySettings(_ result: Result<StoreSettings, Error>) -> Bool {
        switch result {
        case .success(let settings):
            maximumQuantity = settings.maximumCartItemQuantity
            hasLoadedSettings = true
            return true
        case .failure(let error):
            hasLoadedSettings = false
            isLoaded = false
            if items.isEmpty { mode = .make(from: .failure(error), isEmpty: { $0.isEmpty }) }
            return false
        }
    }

    func apply(_ result: Result<[CartItem], Error>) {
        switch result {
        case .success(let records):
            let products = Dictionary(catalogProducts.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
            items = records.compactMap { record in
                products[record.productID].map {
                    CartItemViewModel(id: record.id, product: $0, size: record.size, quantity: record.quantity)
                }
            }
            isLoaded = hasLoadedSettings
            errorMessage = nil
            updateMode()
        case .failure(let error):
            isLoaded = false
            if items.isEmpty { mode = .make(from: .failure(error), isEmpty: { $0.isEmpty }) }
        }
    }

    func reload() {
        Task { [weak self] in await self?.load() }
    }

    /// Загружает настройки магазина, затем корзину.
    func load() async {
        guard let ownerID else { return }
        if items.isEmpty { mode = .loading }
        do {
            applySettings(.success(try await getSettingsUseCase.execute()))
        } catch {
            applySettings(.failure(error))
            return
        }
        do {
            apply(.success(try await cartUseCases.get.execute(ownerID: ownerID)))
        } catch {
            apply(.failure(error))
        }
    }

    // MARK: - Позиции

    func item(productID: String, size: String?) -> CartItemViewModel? {
        items.first { $0.product.id == productID && $0.size == size }
    }

    /// Можно ли добавить товар с выбранным размером или убрать уже добавленную позицию.
    func canToggle(_ product: CatalogItemViewModel, size: String?) -> Bool {
        guard isLoaded else { return false }
        if item(productID: product.id, size: size) != nil { return true }
        return isValid(size: size, for: product)
    }

    /// Добавляет товар или убирает уже добавленную позицию с тем же размером.
    func toggle(_ product: CatalogItemViewModel, size: String?) {
        if let existing = item(productID: product.id, size: size) {
            remove(existing.id)
        } else {
            add(product, size: size)
        }
    }

    func add(_ product: CatalogItemViewModel, size: String?) {
        guard isValid(size: size, for: product) else { return }
        if let existing = item(productID: product.id, size: size) {
            guard existing.quantity < maximumQuantity else { return }
            save(existing, product: product, quantity: existing.quantity + 1)
        } else {
            let item = CartItemViewModel(
                id: Self.positionID(productID: product.id, size: size),
                product: product,
                size: size,
                quantity: 1
            )
            save(item, product: product, quantity: 1)
        }
    }

    func changeQuantity(_ id: String, by delta: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        let quantity = item.quantity + delta
        if quantity == 0 {
            remove(id)
            return
        }
        guard quantity >= 1, delta <= 0 || quantity <= maximumQuantity else { return }
        save(item, product: item.product, quantity: quantity)
    }

    func remove(_ id: String) {
        guard items.contains(where: { $0.id == id }), !pendingItemIDs.contains(id) else { return }
        #if DEBUG
        if isPreview {
            items.removeAll { $0.id == id }
            updateMode()
            return
        }
        #endif
        guard let ownerID else { return }
        pendingItemIDs.insert(id)
        Task { [weak self] in await self?.performRemove(id, ownerID: ownerID) }
    }

    /// Очищает корзину. Возвращает `true`, если позиции удалены.
    func clear() async -> Bool {
        guard !items.isEmpty, pendingItemIDs.isEmpty else { return items.isEmpty }
        #if DEBUG
        if isPreview {
            items = []
            updateMode()
            return true
        }
        #endif
        guard let ownerID else { return false }
        let ids = items.map(\.id)
        pendingItemIDs.formUnion(ids)
        defer { pendingItemIDs.subtract(ids) }
        do {
            try await cartUseCases.clear.execute(ownerID: ownerID, itemIDs: ids)
            items = []
            errorMessage = nil
            updateMode()
            return true
        } catch {
            errorMessage = SwiftGen.Cart.updateFailed
            return false
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Вспомогательное

    private func isValid(size: String?, for product: CatalogItemViewModel) -> Bool {
        if product.sizes.isEmpty { return size == nil }
        guard let size else { return false }
        return product.sizes.contains(size)
    }

    private func save(_ item: CartItemViewModel, product: CatalogItemViewModel, quantity: Int) {
        guard !pendingItemIDs.contains(item.id) else { return }
        #if DEBUG
        if isPreview {
            applySavedItem(item, product: product, quantity: quantity)
            return
        }
        #endif
        guard let ownerID, isLoaded else { return }
        pendingItemIDs.insert(item.id)
        Task { [weak self] in
            await self?.performSave(item, product: product, quantity: quantity, ownerID: ownerID)
        }
    }

    private func performSave(
        _ item: CartItemViewModel,
        product: CatalogItemViewModel,
        quantity: Int,
        ownerID: String
    ) async {
        defer { pendingItemIDs.remove(item.id) }
        let domainItem = CartItem(id: item.id, productID: product.id, size: item.size, quantity: quantity)
        do {
            try await cartUseCases.add.execute(ownerID: ownerID, item: domainItem)
            applySavedItem(item, product: product, quantity: quantity)
            errorMessage = nil
        } catch {
            errorMessage = SwiftGen.Cart.updateFailed
        }
    }

    private func performRemove(_ id: String, ownerID: String) async {
        defer { pendingItemIDs.remove(id) }
        do {
            try await cartUseCases.remove.execute(ownerID: ownerID, itemID: id)
            items.removeAll { $0.id == id }
            errorMessage = nil
            updateMode()
        } catch {
            errorMessage = SwiftGen.Cart.updateFailed
        }
    }

    private func applySavedItem(_ item: CartItemViewModel, product: CatalogItemViewModel, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].product = product
            items[index].quantity = quantity
        } else {
            items.append(CartItemViewModel(id: item.id, product: product, size: item.size, quantity: quantity))
        }
        updateMode()
    }

    private func updateMode() {
        mode = items.isEmpty ? .empty : .content(items)
    }

    /// Стабильный id документа позиции: один и тот же товар с тем же размером — одна позиция.
    private static func positionID(productID: String, size: String?) -> String {
        ["product:\(productID)", size.map { "size:\($0)" } ?? "size:none"]
            .map {
                Data($0.utf8).base64EncodedString()
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "=", with: "")
            }
            .joined(separator: ".")
    }
}
