import Foundation

enum FirestoreDataSourceError: LocalizedError {
    case missingStoreSettings

    var errorDescription: String? {
        "В Firestore отсутствует документ settings/store."
    }
}
