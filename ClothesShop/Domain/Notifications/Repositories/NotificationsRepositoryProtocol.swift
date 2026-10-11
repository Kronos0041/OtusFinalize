protocol NotificationsRepositoryProtocol {
    func fetchNotifications() async throws -> [Notification]
    func readNotificationIDs() -> Set<String>
    func saveReadNotificationIDs(_ ids: Set<String>)
}
