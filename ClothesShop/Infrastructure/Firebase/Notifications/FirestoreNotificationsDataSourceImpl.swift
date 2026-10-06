import FirebaseFirestore

final class FirestoreNotificationsDataSourceImpl: NotificationsRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchNotifications() async throws -> [NotificationDTO] {
        let query = database.collection(FirestoreCollection.notifications.rawValue)
        return try await FirestoreDecoder.documents(of: query).map { document in
            let data = document.data()
            return NotificationDTO(id: document.documentID,
                                   remoteID: data["id"] as? Int ?? 0,
                                   title: data["title"] as? String ?? "",
                                   description: data["description"] as? String ?? "")
        }
    }
}
