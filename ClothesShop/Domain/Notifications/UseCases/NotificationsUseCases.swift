/// Операции над уведомлениями: загрузка списка и состояние «прочитано».
struct NotificationsUseCases {
    let get: GetNotificationsUseCase
    let readIDs: GetReadNotificationIDsUseCase
    let markRead: MarkNotificationReadUseCase

    init(repository: NotificationsRepositoryProtocol) {
        get = GetNotificationsUseCase(repository: repository)
        readIDs = GetReadNotificationIDsUseCase(repository: repository)
        markRead = MarkNotificationReadUseCase(repository: repository)
    }
}
