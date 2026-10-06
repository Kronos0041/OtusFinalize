struct GetReadNotificationIDsUseCase {
    private let repository: NotificationsRepositoryProtocol

    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }

    func execute() -> Set<String> { repository.readNotificationIDs() }
}
