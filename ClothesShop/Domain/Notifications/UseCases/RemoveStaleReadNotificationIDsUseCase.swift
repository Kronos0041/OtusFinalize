/// Убирает из прочитанных id уведомлений, которых больше нет на сервере.
struct RemoveStaleReadNotificationIDsUseCase {
    private let repository: NotificationsRepositoryProtocol

    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }

    /// Сохраняет результат, только если что-то удалено.
    func removeStaleIDs(currentIDs: Set<String>, notifications: [Notification]) -> Set<String> {
        let result = currentIDs.intersection(notifications.map(\.id))
        if result != currentIDs { repository.saveReadNotificationIDs(result) }
        return result
    }
}
