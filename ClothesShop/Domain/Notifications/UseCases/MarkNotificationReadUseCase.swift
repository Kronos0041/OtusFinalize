struct MarkNotificationReadUseCase {
    private let repository: NotificationsRepositoryProtocol

    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }

    func markRead(notificationID: String, currentIDs: Set<String>) -> Set<String> {
        var result = currentIDs
        result.insert(notificationID)
        repository.saveReadNotificationIDs(result)
        return result
    }
}
