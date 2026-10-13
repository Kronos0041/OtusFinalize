#if DEBUG
import Foundation

/// Корзина в памяти: добавление, изменение количества и удаление работают прямо в превью.
final class MockCartRepository: CartRepositoryProtocol {
    private var items: [CartItem]

    init(items: [CartItem]) {
        self.items = items
    }

    func fetchCart(ownerID: String) async throws -> [CartItem] { items }

    func saveCartItem(ownerID: String, item: CartItem) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func deleteCartItem(ownerID: String, itemID: String) async throws {
        items.removeAll { $0.id == itemID }
    }

    func clearCart(ownerID: String, itemIDs: [String]) async throws {
        items.removeAll { itemIDs.contains($0.id) }
    }
}
#endif
