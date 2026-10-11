#if DEBUG
import Foundation

/// Ответ fake-репозитория в SwiftUI Preview.
///
/// Через него превью задаёт состояние экрана, не трогая ViewModel:
/// данные → контент или «пусто», ошибка → экран ошибки, `loading` → бесконечная загрузка.
enum PreviewResponse<Value> {
    case success(Value)
    case failure(Error)
    /// Запрос не завершается: экран остаётся в состоянии загрузки.
    case loading

    func value() async throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        case .loading:
            while true {
                try await Task.sleep(for: .seconds(3600))
            }
        }
    }
}

/// Ошибка для превью экрана ошибки. Текст попадает в `ViewMode.error`.
struct PreviewError: LocalizedError {
    let errorDescription: String?

    init(_ message: String) {
        errorDescription = message
    }
}

// MARK: - Auth

final class PreviewAuthRepository: AuthRepositoryProtocol {
    private(set) var session: AuthSession

    var currentUserID: String? { session == .signedOut ? nil : PreviewData.ownerID }

    init(session: AuthSession) {
        self.session = session
    }

    func signIn(email: String, password: String) async throws {}
    func register(email: String, password: String) async throws {}
    func sendEmailVerification() async throws {}
    func refreshEmailVerification() async throws -> Bool { session == .verified }
    func signOut() throws {}

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        handler(session)
        return ObservationToken {}
    }
}

final class PreviewProfileRepository: ProfileRepositoryProtocol {
    let currentProfile: UserProfile
    private let response: PreviewResponse<UserProfile>

    init(response: PreviewResponse<UserProfile>) {
        self.response = response
        if case .success(let profile) = response {
            currentProfile = profile
        } else {
            currentProfile = UserProfile(email: "")
        }
    }

    func refreshProfile() async throws -> UserProfile { try await response.value() }
    func changePassword(currentPassword: String, newPassword: String) async throws {}
    func changeEmail(to email: String, currentPassword: String) async throws {}
}

// MARK: - Catalog

final class PreviewCatalogRepository: CatalogRepositoryProtocol {
    private let response: PreviewResponse<Catalog>

    init(response: PreviewResponse<Catalog>) {
        self.response = response
    }

    func fetchCatalog() async throws -> Catalog { try await response.value() }
}

final class PreviewFavoritesRepository: FavoritesRepositoryProtocol {
    private var ids: Set<String>

    init(ids: Set<String>) {
        self.ids = ids
    }

    func favoriteProductIDs(ownerID: String) -> Set<String> { ids }
    func saveFavoriteProductIDs(_ ids: Set<String>, ownerID: String) { self.ids = ids }
}

// MARK: - Cart

/// Корзина в памяти: добавление, изменение количества и удаление работают прямо в превью.
final class PreviewCartRepository: CartRepositoryProtocol {
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

final class PreviewStoreSettingsRepository: StoreSettingsRepositoryProtocol {
    private let response: PreviewResponse<StoreSettings>

    init(response: PreviewResponse<StoreSettings>) {
        self.response = response
    }

    func fetchSettings() async throws -> StoreSettings { try await response.value() }
}

// MARK: - Notifications

final class PreviewNotificationsRepository: NotificationsRepositoryProtocol {
    private let response: PreviewResponse<[Notification]>
    private var readIDs: Set<String>

    init(response: PreviewResponse<[Notification]>, readIDs: Set<String>) {
        self.response = response
        self.readIDs = readIDs
    }

    func fetchNotifications() async throws -> [Notification] { try await response.value() }
    func readNotificationIDs() -> Set<String> { readIDs }
    func saveReadNotificationIDs(_ ids: Set<String>) { readIDs = ids }
}

// MARK: - Infrastructure

/// Фиксированное состояние сети: `false` даёт экраны «нет интернета».
struct PreviewConnectivityRepository: ConnectivityRepositoryProtocol {
    let isConnected: Bool

    func updates() -> AsyncStream<Bool> {
        AsyncStream { $0.finish() }
    }
}

struct PreviewImageCacheRepository: ImageCacheRepositoryProtocol {
    func updateCapacity(memoryCapacityMB: Int, diskCapacityMB: Int) {}
}
#endif
