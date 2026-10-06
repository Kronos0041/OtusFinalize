import FirebaseFirestore

final class FirestoreCartDataSourceImpl: CartRemoteDataSourceProtocol {
    private let database: Firestore

    init(database: Firestore) {
        self.database = database
    }

    func fetchCart(ownerID: String, completion: @escaping (Result<[CartRecordDTO], Error>) -> Void) {
        collection(ownerID: ownerID).getDocuments { snapshot, error in
            completion(FirestoreDecoder.documents(snapshot, error).map { documents in
                documents.compactMap { document in
                    let data = document.data()
                    guard let productID = data["productId"] as? String,
                          let quantity = data["quantity"] as? Int,
                          quantity > 0 else { return nil }
                    return CartRecordDTO(id: document.documentID, productID: productID,
                                         size: data["size"] as? String, quantity: quantity)
                }
            })
        }
    }

    func saveCartItem(ownerID: String, item: CartRecordDTO,
                      completion: @escaping (Result<Void, Error>) -> Void) {
        collection(ownerID: ownerID).document(item.id).setData([
            "productId": item.productID,
            "size": item.size ?? NSNull(),
            "quantity": item.quantity,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in completion(error.map { .failure(FirestoreErrorMapper.map($0)) } ?? .success(())) }
    }

    func deleteCartItem(ownerID: String, itemID: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        collection(ownerID: ownerID).document(itemID).delete {
            completion($0.map { .failure(FirestoreErrorMapper.map($0)) } ?? .success(()))
        }
    }

    func clearCart(ownerID: String, itemIDs: [String],
                   completion: @escaping (Result<Void, Error>) -> Void) {
        guard !itemIDs.isEmpty else { completion(.success(())); return }
        let batch = database.batch()
        itemIDs.forEach { batch.deleteDocument(collection(ownerID: ownerID).document($0)) }
        batch.commit { completion($0.map { .failure(FirestoreErrorMapper.map($0)) } ?? .success(())) }
    }

    private func collection(ownerID: String) -> CollectionReference {
        database.collection(FirestoreCollection.users.rawValue)
            .document(ownerID).collection("cart")
    }
}
