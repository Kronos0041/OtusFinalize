struct GetReadNotificationIDsUseCase {
    private let repository: NotificationsRepositoryProtocol

    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }

    func getReadNotificationIDs() -> Set<String> { repository.readNotificationIDs() }
}
