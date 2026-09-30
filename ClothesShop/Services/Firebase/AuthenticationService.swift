//
//  AuthenticationService.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import Foundation
import FirebaseAuth

/// Обёртка над FirebaseAuth. Ничего не знает про UI, а FirebaseAuth не протекает наружу:
/// ViewModel работает только с `Result` и `AuthStateObservation`.
/// Firebase Auth вызывает completion-блоки публичных методов и слушатель сессии
/// на главной очереди, поэтому сервис не делает повторный dispatch.
enum AuthenticationService {
    typealias Completion = (Result<Void, Error>) -> Void

    /// После создания аккаунта Firebase сразу открывает сессию. Отправляем письмо,
    /// а доступ к приложению до подтверждения блокирует `AuthSessionState`.
    static func register(email: String, password: String, completion: @escaping Completion) {
        Auth.auth().languageCode = "ru"
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else {
                completion(.failure(missingUserError))
                return
            }
            user.sendEmailVerification { error in
                completion(error.map(Result.failure) ?? .success(()))
            }
        }
    }

    /// Вход существующего пользователя.
    static func signIn(email: String, password: String, completion: @escaping Completion) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            deliver(result: result, error: error, to: completion)
        }
    }

    /// Состояние сохранённой сессии, доступное до первого вызова слушателя.
    static var sessionState: AuthSessionState {
        guard let user = Auth.auth().currentUser else { return .signedOut }
        return state(for: user)
    }

    static func sendEmailVerification(completion: @escaping Completion) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(missingUserError))
            return
        }
        Auth.auth().languageCode = "ru"
        user.sendEmailVerification { error in
            completion(error.map(Result.failure) ?? .success(()))
        }
    }

    /// После перехода по ссылке обновляем пользователя и токен для правил Firestore.
    static func refreshEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(missingUserError))
            return
        }
        user.reload { error in
            if let error {
                completion(.failure(error))
                return
            }
            guard user.isEmailVerified else {
                completion(.success(false))
                return
            }
            user.getIDTokenForcingRefresh(true) { _, error in
                completion(error.map(Result.failure) ?? .success(true))
            }
        }
    }

    /// Выход из аккаунта. Слушатель `observeAuthState` получит `false`.
    static func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Подписка на состояние авторизации и подтверждения email.
    /// Подписка живёт, пока жив возвращённый объект.
    static func observeAuthState(_ handler: @escaping (AuthSessionState) -> Void) -> AuthStateObservation {
        let handle = Auth.auth().addStateDidChangeListener { _, user in
            handler(user.map(state(for:)) ?? .signedOut)
        }
        return AuthStateObservation(handle: handle)
    }

    private static func state(for user: User) -> AuthSessionState {
        user.isEmailVerified ? .verified : .awaitingEmailVerification(user.email ?? "")
    }

    private static var missingUserError: Error {
        NSError(domain: "ClothesShop.Auth", code: 1,
                userInfo: [NSLocalizedDescriptionKey: String(localized: "Сессия завершилась. Войдите снова.")])
    }

    private static func deliver(result: AuthDataResult?, error: Error?, to completion: @escaping Completion) {
        if let error = error {
            completion(.failure(error))
        } else if result != nil {
            completion(.success(()))
        }
    }
}

/// Токен подписки на `Auth`. Снимает слушателя при освобождении — не нужно помнить про `deinit`.
final class AuthStateObservation {
    private let handle: AuthStateDidChangeListenerHandle

    fileprivate init(handle: AuthStateDidChangeListenerHandle) {
        self.handle = handle
    }

    deinit {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
