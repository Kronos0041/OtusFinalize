#if DEBUG
import Foundation

final class MockNotificationsRepository: NotificationsRepositoryProtocol {
    private let response: MockResponse<[Notification]>
    private var readIDs: Set<String>

    init(response: MockResponse<[Notification]>, readIDs: Set<String>) {
        self.response = response
        self.readIDs = readIDs
    }

    func fetchNotifications() async throws -> [Notification] { try await response.value() }
    func readNotificationIDs() -> Set<String> { readIDs }
    func saveReadNotificationIDs(_ ids: Set<String>) { readIDs = ids }
}
#endif
