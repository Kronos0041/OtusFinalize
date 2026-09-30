//
//  ProfileViewState.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation

/// Изменяемое состояние, которое отображает экран профиля.
///
/// Это UI-модель, а не документ Firestore: сервис преобразует удалённый профиль
/// в эти поля, а экран может локально редактировать имя пользователя.
struct ProfileViewState {
    var id: Int
    var name: String
    var age: Int
    var image: String?
}
