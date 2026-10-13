final class NotificationsRepositoryImpl: NotificationsRepositoryProtocol {
    private let remoteDataSource: NotificationsRemoteDataSourceProtocol
    private let localDataSource: NotificationsLocalDataSourceProtocol

    init(remoteDataSource: NotificationsRemoteDataSourceProtocol,
         localDataSource: NotificationsLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchNotifications() async throws -> [Notification] {
        try await remoteDataSource.fetchNotifications().map(NotificationMapper.map)
    }

    func readNotificationIDs() -> Set<String> {
        localDataSource.readNotificationIDs()
    }

    func saveReadNotificationIDs(_ ids: Set<String>) {
        localDataSource.saveReadNotificationIDs(ids)
    }
}
