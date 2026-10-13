protocol NotificationsLocalDataSourceProtocol {
    func readNotificationIDs() -> Set<String>
    func saveReadNotificationIDs(_ ids: Set<String>)
}
