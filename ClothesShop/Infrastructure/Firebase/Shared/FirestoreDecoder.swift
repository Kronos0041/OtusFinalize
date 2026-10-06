import FirebaseFirestore
import os

/// Общие операции чтения и записи Firestore с переводом ошибок в доменные.
enum FirestoreDecoder {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "ClothesShop",
        category: "Firestore"
    )

    /// Читает коллекцию и декодирует документы. Некорректные документы пропускаются и логируются.
    static func fetchAll<T: Decodable>(
        _ collection: FirestoreCollection,
        from database: Firestore,
        as type: T.Type
    ) async throws -> [T] {
        let snapshots = try await Self.documents(of: database.collection(collection.rawValue))
        return snapshots.compactMap { document in
            do {
                return try document.data(as: T.self)
            } catch {
                logger.error("Документ \(collection.rawValue, privacy: .public)/\(document.documentID, privacy: .public) пропущен: \(error.localizedDescription, privacy: .public)")
                return nil
            }
        }
    }

    static func documents(of query: Query) async throws -> [QueryDocumentSnapshot] {
        try await perform { try await query.getDocuments().documents }
    }

    static func document(_ reference: DocumentReference) async throws -> DocumentSnapshot {
        try await perform { try await reference.getDocument() }
    }

    static func perform<Value>(_ operation: () async throws -> Value) async throws -> Value {
        do {
            return try await operation()
        } catch {
            throw FirestoreErrorMapper.map(error)
        }
    }
}
