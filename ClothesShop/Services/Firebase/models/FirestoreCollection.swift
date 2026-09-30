//
//  FirestoreCollection.swift
//  ClothesShop
//
//  Created by Alex on 29.09.2026.
//

import Foundation

/// Имена коллекций Cloud Firestore, используемых приложением.
/// Хранятся отдельно от запросов, чтобы схема базы не была разбросана по сервисам.
enum FirestoreCollection: String {
    case categories
    case products
    case notifications = "notificationList"
    case profile = "prof"
}
