protocol NotificationsRemoteDataSourceProtocol {
    func fetchNotifications(completion: @escaping (Result<[NotificationDTO], Error>) -> Void)
}
