enum NotificationMapper {
    static func map(_ dto: NotificationDTO) -> Notification {
        Notification(id: dto.id, remoteID: dto.remoteID,
                     title: dto.title, description: dto.description)
    }
}
