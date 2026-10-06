

import Combine
import Foundation

final class CartViewModel: ObservableObject {
    @Published private(set) var items: [CartItemViewModel] = []
    @Published private(set) var mode: ViewMode<[CartItemViewModel]> = .loading
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoaded = false
    @Published private(set) var maximumQuantity = StoreSettings.preview.maximumCartItemQuantity

    var count: Int { items.reduce(0) { $0 + $1.quantity } }

    private let ownerID: String?
    private let getCartUseCase: GetCartUseCase
    private let addCartItemUseCase: AddCartItemUseCase
    private let removeCartItemUseCase: RemoveCartItemUseCase
    private let clearCartUseCase: ClearCartUseCase
    private let getSettingsUseCase: GetStoreSettingsUseCase
    private var pendingItemIDs: Set<String> = []
    private var hasLoadedSettings = false
    #if DEBUG
    private var isPreview = false
    #endif

    init(ownerID: String?, getCartUseCase: GetCartUseCase,
         addCartItemUseCase: AddCartItemUseCase,
         removeCartItemUseCase: RemoveCartItemUseCase,
         clearCartUseCase: ClearCartUseCase,
         getSettingsUseCase: GetStoreSettingsUseCase) {
        self.ownerID = ownerID
        self.getCartUseCase = getCartUseCase
        self.addCartItemUseCase = addCartItemUseCase
        self.removeCartItemUseCase = removeCartItemUseCase
        self.clearCartUseCase = clearCartUseCase
        self.getSettingsUseCase = getSettingsUseCase
        #if DEBUG
        if ownerID == nil { isPreview = true; isLoaded = true; hasLoadedSettings = true; mode = .empty }
        #endif
    }

    @discardableResult
    func applySettings(_ result: Result<StoreSettings, Error>) -> Bool {
        switch result {
        case .success(let settings):
            guard (1...999).contains(settings.maximumCartItemQuantity) else {
                return applySettings(.failure(CartSettingsError.invalidMaximumQuantity))
            }
            maximumQuantity = settings.maximumCartItemQuantity
            hasLoadedSettings = true
            return true
        case .failure(let error):
            hasLoadedSettings = false; isLoaded = false
            if items.isEmpty { mode = .make(from: .failure(error), isEmpty: { $0.isEmpty }) }
            return false
        }
    }

    func apply(_ result: Result<[CartItem], Error>, catalog: [CatalogItemViewModel]) {
        switch result {
        case .success(let records):
            let products = Dictionary(catalog.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
            items = records.compactMap { record in
                products[record.productID].map {
                    CartItemViewModel(id: record.id, product: $0,
                                      size: record.size, quantity: record.quantity)
                }
            }
            isLoaded = hasLoadedSettings; errorMessage = nil; updateMode()
        case .failure(let error):
            isLoaded = false
            if items.isEmpty { mode = .make(from: .failure(error), isEmpty: { $0.isEmpty }) }
        }
    }

    func reload(catalog: [CatalogItemViewModel]) {
        guard let ownerID else { return }
        if items.isEmpty { mode = .loading }
        getSettingsUseCase.execute { [weak self] settings in
            guard let self, self.applySettings(settings) else { return }
            self.getCartUseCase.execute(ownerID: ownerID) { [weak self] in self?.apply($0, catalog: catalog) }
        }
    }

    func add(_ product: CatalogItemViewModel, size: String?) {
        if product.sizes.isEmpty { guard size == nil else { return } }
        else { guard let size, product.sizes.contains(size) else { return } }

        if let existing = items.first(where: { $0.product.id == product.id && $0.size == size }) {
            guard existing.quantity < maximumQuantity else { return }
            save(existing, product: product, quantity: existing.quantity + 1)
        } else {
            save(CartItemViewModel(id: Self.positionID(productID: product.id, size: size),
                                   product: product, size: size, quantity: 1),
                 product: product, quantity: 1)
        }
    }

    func changeQuantity(_ id: String, by delta: Int) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        let quantity = item.quantity + delta
        if quantity == 0 { remove(id); return }
        guard quantity >= 1, delta <= 0 || quantity <= maximumQuantity else { return }
        save(item, product: item.product, quantity: quantity)
    }

    func remove(_ id: String) {
        guard let item = items.first(where: { $0.id == id }),
              !pendingItemIDs.contains(id) else { return }
        #if DEBUG
        if isPreview { items.removeAll { $0.id == id }; updateMode(); return }
        #endif
        guard let ownerID else { return }
        pendingItemIDs.insert(id)
        removeCartItemUseCase.execute(ownerID: ownerID, itemID: id) { [weak self] result in
            guard let self else { return }
            self.pendingItemIDs.remove(id)
            switch result {
            case .success: self.items.removeAll { $0.id == item.id }; self.errorMessage = nil; self.updateMode()
            case .failure: self.errorMessage = SwiftGen.Cart.updateFailed
            }
        }
    }

    func clear(completion: @escaping (Bool) -> Void = { _ in }) {
        guard !items.isEmpty, pendingItemIDs.isEmpty else { completion(items.isEmpty); return }
        #if DEBUG
        if isPreview { items = []; updateMode(); completion(true); return }
        #endif
        guard let ownerID else { completion(false); return }
        let ids = items.map(\.id)
        pendingItemIDs.formUnion(ids)
        clearCartUseCase.execute(ownerID: ownerID, itemIDs: ids) { [weak self] result in
            guard let self else { return }
            self.pendingItemIDs.subtract(ids)
            switch result {
            case .success: self.items = []; self.errorMessage = nil; self.updateMode(); completion(true)
            case .failure: self.errorMessage = SwiftGen.Cart.updateFailed; completion(false)
            }
        }
    }

    func resolvedItems(in catalog: [CatalogItemViewModel]) -> [CartItemViewModel] {
        let products = Dictionary(catalog.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
        return items.map { item in
            var result = item; result.product = products[item.product.id] ?? item.product; return result
        }
    }

    func dismissError() { errorMessage = nil }

    private func save(_ item: CartItemViewModel, product: CatalogItemViewModel, quantity: Int) {
        guard !pendingItemIDs.contains(item.id) else { return }
        #if DEBUG
        if isPreview { applySavedItem(item, product: product, quantity: quantity); return }
        #endif
        guard let ownerID, isLoaded else { return }
        pendingItemIDs.insert(item.id)
        let domainItem = CartItem(id: item.id, productID: product.id, size: item.size, quantity: quantity)
        addCartItemUseCase.execute(ownerID: ownerID, item: domainItem) { [weak self] result in
            guard let self else { return }
            self.pendingItemIDs.remove(item.id)
            switch result {
            case .success: self.applySavedItem(item, product: product, quantity: quantity); self.errorMessage = nil
            case .failure: self.errorMessage = SwiftGen.Cart.updateFailed
            }
        }
    }

    private func applySavedItem(_ item: CartItemViewModel,
                                product: CatalogItemViewModel, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].product = product; items[index].quantity = quantity
        } else {
            items.append(CartItemViewModel(id: item.id, product: product,
                                           size: item.size, quantity: quantity))
        }
        updateMode()
    }

    private func updateMode() { mode = items.isEmpty ? .empty : .content(items) }

    private static func positionID(productID: String, size: String?) -> String {
        ["product:\(productID)", size.map { "size:\($0)" } ?? "size:none"]
            .map { Data($0.utf8).base64EncodedString()
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "=", with: "") }
            .joined(separator: ".")
    }
}
