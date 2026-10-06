protocol NotificationsRemoteDataSourceProtocol {
    func fetchNotifications() async throws -> [NotificationDTO]
}
