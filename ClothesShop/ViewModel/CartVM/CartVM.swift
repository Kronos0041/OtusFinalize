import Foundation
import Combine

struct CartItem: Identifiable, Codable {
    let id: UUID
    var product: MainGrideDateModel
    let size: String?
    var quantity: Int
}

final class CartVM: ObservableObject {
    static let maximumQuantity = 99
    @Published private(set) var items: [CartItem]

    var count: Int { items.reduce(0) { $0 + $1.quantity } }
    var viewMode: ViewMode<[CartItem]> { items.isEmpty ? .empty : .content(items) }
    private let defaults: UserDefaults
    private let storageKey: String?

    init(ownerID: String? = AuthenticationService.currentUserID, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        storageKey = ownerID.map { "cart.\($0)" }
        if let storageKey, let data = defaults.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = saved.filter { (1...Self.maximumQuantity).contains($0.quantity) }
        } else {
            items = []
        }
    }

    func add(_ product: MainGrideDateModel, size: String?) {
        if product.sizes.isEmpty {
            guard size == nil else { return }
        } else {
            guard let size, product.sizes.contains(size) else { return }
        }
        if let index = items.firstIndex(where: { $0.product.id == product.id && $0.size == size }) {
            guard items[index].quantity < Self.maximumQuantity else { return }
            items[index].product = product
            items[index].quantity += 1
        } else {
            items.append(CartItem(id: UUID(), product: product, size: size, quantity: 1))
        }
        save()
    }

    func changeQuantity(_ id: UUID, by delta: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let quantity = items[index].quantity + delta
        if quantity == 0 {
            items.remove(at: index)
            save()
            return
        }
        guard (1...Self.maximumQuantity).contains(quantity) else { return }
        items[index].quantity = quantity
        save()
    }

    func remove(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    func clear() {
        items = []
        save()
    }

    func resolvedItems(in catalog: [MainGrideDateModel]) -> [CartItem] {
        let products = Dictionary(catalog.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
        return items.map { item in
            var result = item
            result.product = products[item.product.id] ?? item.product
            return result
        }
    }

    private func save() {
        guard let storageKey, let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
