struct GetNotificationsUseCase {
    private let repository: NotificationsRepositoryProtocol

    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }

    func execute(completion: @escaping (Result<[Notification], Error>) -> Void) {
        repository.fetchNotifications(completion: completion)
    }
}
