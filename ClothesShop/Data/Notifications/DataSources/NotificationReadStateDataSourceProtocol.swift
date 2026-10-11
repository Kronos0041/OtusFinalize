protocol NotificationReadStateDataSourceProtocol {
    func readNotificationIDs() -> Set<String>
    func saveReadNotificationIDs(_ ids: Set<String>)
}
