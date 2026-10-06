import FirebaseFirestore

enum FirestoreDecoder {
    static func fetchAll<T: Decodable>(_ collection: FirestoreCollection,
                                       from database: Firestore,
                                       as type: T.Type,
                                       completion: @escaping (Result<[T], Error>) -> Void) {
        database.collection(collection.rawValue).getDocuments { snapshot, error in
            completion(documents(snapshot, error).map { documents in
                documents.compactMap { document in
                    do { return try document.data(as: T.self) }
                    catch {
                        print("Firestore: \(collection.rawValue)/\(document.documentID) пропущен: \(error)")
                        return nil
                    }
                }
            })
        }
    }

    static func documents(_ snapshot: QuerySnapshot?, _ error: Error?)
        -> Result<[QueryDocumentSnapshot], Error> {
        if let error { return .failure(FirestoreErrorMapper.map(error)) }
        return .success(snapshot?.documents ?? [])
    }
}
