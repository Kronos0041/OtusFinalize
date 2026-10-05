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

    static var currentUserID: String? { Auth.auth().currentUser?.uid }

    static var profile: ProfileViewState {
        ProfileViewState(email: Auth.auth().currentUser?.email ?? "")
    }

    /// Обновляет email после подтверждения смены адреса в браузере.
    static func refreshProfile(completion: @escaping (Result<ProfileViewState, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(missingUserError))
            return
        }
        user.reload { error in
            if let error {
                completion(.failure(error))
                return
            }
            user.getIDTokenForcingRefresh(true) { _, error in
                completion(error.map(Result.failure) ?? .success(profile))
            }
        }
    }

    static func changePassword(currentPassword: String, newPassword: String,
                               completion: @escaping Completion) {
        reauthenticate(password: currentPassword) { result in
            switch result {
            case .success(let user):
                user.updatePassword(to: newPassword) { error in
                    completion(error.map(Result.failure) ?? .success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Firebase применит новый адрес только после перехода по ссылке из письма.
    static func changeEmail(to email: String, currentPassword: String,
                            completion: @escaping Completion) {
        reauthenticate(password: currentPassword) { result in
            switch result {
            case .success(let user):
                Auth.auth().languageCode = Bundle.main.preferredLocalizations.first ?? "en"
                user.sendEmailVerification(beforeUpdatingEmail: email) { error in
                    completion(error.map(Result.failure) ?? .success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    static func accountErrorMessage(_ error: Error, verifyingCurrentPassword: Bool = true) -> String {
        let error = error as NSError
        guard error.domain == AuthErrorDomain else { return error.localizedDescription }
        switch AuthErrorCode(rawValue: error.code) {
        case .wrongPassword, .invalidCredential:
            return verifyingCurrentPassword ? SwiftGen.Auth.Error.wrongPassword : SwiftGen.Auth.Error.invalidCredentials
        case .userNotFound:
            return SwiftGen.Auth.Error.invalidCredentials
        case .userDisabled:
            return SwiftGen.Auth.Error.accountDisabled
        case .emailAlreadyInUse:
            return SwiftGen.Auth.Error.emailInUse
        case .invalidEmail:
            return SwiftGen.Auth.Error.invalidEmail
        case .weakPassword:
            return SwiftGen.Auth.Error.weakPassword
        case .networkError:
            return SwiftGen.Network.offline
        case .tooManyRequests:
            return SwiftGen.Auth.Error.tooManyRequests
        case .requiresRecentLogin, .invalidUserToken, .userTokenExpired:
            return SwiftGen.Auth.Error.sessionExpired
        default:
            return SwiftGen.Auth.Error.unexpected
        }
    }

    private static func reauthenticate(password: String,
                                       completion: @escaping (Result<User, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(.failure(missingUserError))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { result, error in
            if let error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(missingUserError))
            }
        }
    }

    /// После создания аккаунта Firebase сразу открывает сессию. Отправляем письмо,
    /// а доступ к приложению до подтверждения блокирует `AuthSessionState`.
    static func register(email: String, password: String, completion: @escaping Completion) {
        Auth.auth().languageCode = Bundle.main.preferredLocalizations.first ?? "en"
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
        Auth.auth().languageCode = Bundle.main.preferredLocalizations.first ?? "en"
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
                userInfo: [NSLocalizedDescriptionKey: SwiftGen.Auth.Error.sessionEnded])
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
