struct GetNotificationsUseCase {
    private let repository: NotificationsRepositoryProtocol

    init(repository: NotificationsRepositoryProtocol) {
        self.repository = repository
    }

    func getNotifications() async throws -> [Notification] {
        try await repository.fetchNotifications()
    }
}
