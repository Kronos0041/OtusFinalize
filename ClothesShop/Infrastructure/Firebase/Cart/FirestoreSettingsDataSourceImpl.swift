import FirebaseFirestore

final class FirestoreSettingsDataSourceImpl: StoreSettingsRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchSettings() async throws -> StoreSettingsDTO {
        let reference = database.collection(FirestoreCollection.settings.rawValue).document("store")
        let document = try await FirestoreDecoder.document(reference)
        guard document.exists else { throw CartSettingsError.missingSettings }
        return try document.data(as: StoreSettingsDTO.self)
    }
}
