import FirebaseFirestore

final class FirestoreCartDataSourceImpl: CartRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchCart(ownerID: String) async throws -> [CartRecordDTO] {
        let documents = try await FirestoreDecoder.documents(of: collection(ownerID: ownerID))
        return documents.compactMap { document in
            let data = document.data()
            guard let productID = data["productId"] as? String,
                  let quantity = data["quantity"] as? Int,
                  quantity > 0 else { return nil }
            return CartRecordDTO(id: document.documentID, productID: productID,
                                 size: data["size"] as? String, quantity: quantity)
        }
    }

    func saveCartItem(ownerID: String, item: CartRecordDTO) async throws {
        let data: [String: Any] = [
            "productId": item.productID,
            "size": item.size ?? NSNull(),
            "quantity": item.quantity,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        let reference = collection(ownerID: ownerID).document(item.id)
        try await FirestoreDecoder.perform { try await reference.setData(data) }
    }

    func deleteCartItem(ownerID: String, itemID: String) async throws {
        let reference = collection(ownerID: ownerID).document(itemID)
        try await FirestoreDecoder.perform { try await reference.delete() }
    }

    /// Удаляет позиции одной `WriteBatch`, то есть атомарно.
    func clearCart(ownerID: String, itemIDs: [String]) async throws {
        guard !itemIDs.isEmpty else { return }
        let batch = database.batch()
        let cart = collection(ownerID: ownerID)
        itemIDs.forEach { batch.deleteDocument(cart.document($0)) }
        try await FirestoreDecoder.perform { try await batch.commit() }
    }

    private func collection(ownerID: String) -> CollectionReference {
        database.collection(FirestoreCollection.users.rawValue)
            .document(ownerID)
            .collection("cart")
    }
}
