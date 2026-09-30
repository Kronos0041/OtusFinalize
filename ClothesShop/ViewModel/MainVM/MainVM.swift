//
//  MainVM.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation

/// ViewModel экрана профиля.
final class MainViewModel: ObservableObject {
    @Published var user = ProfileViewState(id: 0, name: "Alex", age: 27)
    @Published private(set) var signOutError: String?

    func loadProfile() {
        FirestoreService.fetchProfile { [weak self] profile in
            self?.user.name = profile.fullName
            self?.user.image = profile.image
        }
    }

    /// После выхода `LoadPreview` сам вернёт экран входа — через слушатель авторизации.
    func signOut() {
        do {
            try AuthenticationService.signOut()
            signOutError = nil
        } catch {
            signOutError = error.localizedDescription
        }
    }
}
