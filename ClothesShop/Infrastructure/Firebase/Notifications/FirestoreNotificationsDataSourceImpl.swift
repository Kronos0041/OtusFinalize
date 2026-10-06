import FirebaseFirestore

final class FirestoreNotificationsDataSourceImpl: NotificationsRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchNotifications(completion: @escaping (Result<[NotificationDTO], Error>) -> Void) {
        database.collection(FirestoreCollection.notifications.rawValue)
            .getDocuments { snapshot, error in
                completion(FirestoreDecoder.documents(snapshot, error).map { documents in
                    documents.map { document in
                        let data = document.data()
                        return NotificationDTO(id: document.documentID,
                                               remoteID: data["id"] as? Int ?? 0,
                                               title: data["title"] as? String ?? "",
                                               description: data["description"] as? String ?? "")
                    }
                })
            }
    }
}
