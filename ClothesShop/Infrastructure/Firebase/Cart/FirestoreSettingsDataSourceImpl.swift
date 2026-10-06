import FirebaseFirestore

final class FirestoreSettingsDataSourceImpl: StoreSettingsRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchSettings(completion: @escaping (Result<StoreSettingsDTO, Error>) -> Void) {
        database.collection(FirestoreCollection.settings.rawValue)
            .document("store").getDocument { document, error in
                if let error { completion(.failure(FirestoreErrorMapper.map(error))); return }
                guard let document, document.exists else {
                    completion(.failure(FirestoreDataSourceError.missingStoreSettings)); return
                }
                do { completion(.success(try document.data(as: StoreSettingsDTO.self))) }
                catch { completion(.failure(error)) }
            }
    }
}
