final class NotificationsRepositoryImpl: NotificationsRepositoryProtocol {
    private let remoteDataSource: NotificationsRemoteDataSourceProtocol
    private let readStateDataSource: NotificationReadStateDataSourceProtocol

    init(remoteDataSource: NotificationsRemoteDataSourceProtocol,
         readStateDataSource: NotificationReadStateDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.readStateDataSource = readStateDataSource
    }

    func fetchNotifications() async throws -> [Notification] {
        try await remoteDataSource.fetchNotifications().map(NotificationMapper.map)
    }

    func readNotificationIDs() -> Set<String> {
        readStateDataSource.readNotificationIDs()
    }

    func saveReadNotificationIDs(_ ids: Set<String>) {
        readStateDataSource.saveReadNotificationIDs(ids)
    }
}
