protocol NotificationsRepositoryProtocol {
    func fetchNotifications(completion: @escaping (Result<[Notification], Error>) -> Void)
    func readNotificationIDs() -> Set<String>
    func saveReadNotificationIDs(_ ids: Set<String>)
}
