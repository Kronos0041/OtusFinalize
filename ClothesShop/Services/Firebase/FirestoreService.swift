//
//  FirestoreService.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation
import FirebaseFirestore

/// Единая точка чтения данных приложения из Cloud Firestore.
/// Firestore вызывает completion-блоки на `settings.dispatchQueue`; проект использует
/// значение по умолчанию — главную очередь, поэтому повторный dispatch не нужен.
/// Запись с клиента запрещена правилами (`firestore.rules`); данные загружает `firebase/seed`.
enum FirestoreService {
    private static var db: Firestore { Firestore.firestore() }

    static func fetchCatalog(completion: @escaping (Result<CatalogDTO, Error>) -> Void) {
        fetchAll(FirestoreCollection.categories, as: CategoryDTO.self) { categoriesResult in
            switch categoriesResult {
            case .failure(let error):
                completion(.failure(error))
            case .success(let categories):
                fetchAll(FirestoreCollection.products, as: ProductDTO.self) { productsResult in
                    completion(productsResult.map { CatalogDTO(categories: categories, products: $0) })
                }
            }
        }
    }

    static func fetchNotifications(completion: @escaping (Result<[NotificationItem], Error>) -> Void) {
        db.collection(FirestoreCollection.notifications.rawValue).getDocuments { snapshot, error in
            let result = documentsResult(snapshot, error).map { $0.map(NotificationItem.init(document:)) }
            completion(result)
        }
    }

    /// Профиль берётся из последнего документа коллекции. При ошибке колбэк не вызывается.
    static func fetchProfile(completion: @escaping (UserProfile) -> Void) {
        db.collection(FirestoreCollection.profile.rawValue).getDocuments { snapshot, error in
            guard case .success(let documents) = documentsResult(snapshot, error) else { return }
            let profile = documents.last.map(UserProfile.init(document:)) ?? UserProfile()
            completion(profile)
        }
    }

    // MARK: - Helpers

    /// Все документы коллекции, декодированные в `T`. Документы с неверной схемой пропускаются.
    private static func fetchAll<T: Decodable>(_ collection: FirestoreCollection,
                                               as type: T.Type,
                                               completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection.rawValue).getDocuments { snapshot, error in
            let result = documentsResult(snapshot, error).map { documents in
                documents.compactMap { document -> T? in
                    do {
                        return try document.data(as: T.self)
                    } catch {
                        print("Firestore: \(collection.rawValue)/\(document.documentID) пропущен: \(error)")
                        return nil
                    }
                }
            }
            completion(result)
        }
    }

    private static func documentsResult(_ snapshot: QuerySnapshot?, _ error: Error?) -> Result<[QueryDocumentSnapshot], Error> {
        if let error = error {
            print(error.localizedDescription)
            return .failure(error)
        }
        return .success(snapshot?.documents ?? [])
    }
}

// MARK: - Models

struct NotificationItem: Identifiable {
    /// Идентификатор документа Firestore — гарантированно уникален (поле `id` в данных — нет).
    let id: String
    /// Поле `id` из документа — задаёт порядок в списке.
    let remoteId: Int
    let title: String
    let description: String

    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        id = document.documentID
        remoteId = data["id"] as? Int ?? 0
        title = data["title"] as? String ?? ""
        description = data["description"] as? String ?? ""
    }
}

struct UserProfile {
    var remoteId: Int = 0
    var image: String = ""
    var name: String = ""
    var secondName: String = ""

    var fullName: String { "\(secondName) \(name)" }
}

extension UserProfile {
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        remoteId = data["id"] as? Int ?? 0
        image = data["image"] as? String ?? ""
        name = data["name"] as? String ?? ""
        secondName = data["secondname"] as? String ?? ""
    }
}
