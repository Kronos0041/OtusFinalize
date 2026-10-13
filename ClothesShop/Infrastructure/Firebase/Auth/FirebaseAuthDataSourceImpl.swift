import FirebaseAuth
import Foundation

final class FirebaseAuthDataSourceImpl: AuthRemoteDataSourceProtocol {
    var currentUserID: String? { Auth.auth().currentUser?.uid }

    var currentProfile: UserProfile {
        UserProfile(email: Auth.auth().currentUser?.email ?? "")
    }

    var session: AuthSession {
        guard let user = Auth.auth().currentUser else { return .signedOut }
        return session(for: user)
    }

    /// Работает, только если в Firebase Console выключена защита от перебора email
    /// (Authentication → Settings → User actions → Email enumeration protection).
    /// При включённой защите Firebase всегда возвращает пустой список, и приложение откроет регистрацию;
    /// если email на самом деле занят, регистрация вернёт `emailAlreadyInUse` и экран переключится на вход.
    func isEmailRegistered(_ email: String) async throws -> Bool {
        let fetcher: SignInMethodsFetching = Auth.auth()
        return try await mapped { try await !fetcher.fetchSignInMethods(forEmail: email).isEmpty }
    }

    func signIn(email: String, password: String) async throws {
        try await mapped { _ = try await Auth.auth().signIn(withEmail: email, password: password) }
    }

    func register(email: String, password: String) async throws {
        configureLanguage()
        try await mapped {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()
        }
    }

    func sendEmailVerification() async throws {
        let user = try requireUser()
        configureLanguage()
        try await mapped { try await user.sendEmailVerification() }
    }

    func sendPasswordReset(email: String) async throws {
        configureLanguage()
        try await mapped { try await Auth.auth().sendPasswordReset(withEmail: email) }
    }

    func refreshEmailVerification() async throws -> Bool {
        let user = try requireUser()
        try await mapped { try await user.reload() }
        guard user.isEmailVerified else { return false }
        // Новый ID-токен содержит актуальный email_verified — без него правила Firestore отклонят запросы.
        try await mapped { _ = try await user.getIDTokenResult(forcingRefresh: true) }
        return true
    }

    func refreshProfile() async throws -> UserProfile {
        let user = try requireUser()
        try await mapped {
            try await user.reload()
            _ = try await user.getIDTokenResult(forcingRefresh: true)
        }
        return currentProfile
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        let user = try await reauthenticate(password: currentPassword)
        try await mapped { try await user.updatePassword(to: newPassword) }
    }

    func changeEmail(to email: String, currentPassword: String) async throws {
        let user = try await reauthenticate(password: currentPassword)
        configureLanguage()
        try await mapped { try await user.sendEmailVerification(beforeUpdatingEmail: email) }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw FirebaseAuthErrorMapper.map(error)
        }
    }

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        let handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            handler(user.map(self.session(for:)) ?? .signedOut)
        }
        return ObservationToken { Auth.auth().removeStateDidChangeListener(handle) }
    }

    // MARK: - Вспомогательное

    private func requireUser() throws -> User {
        guard let user = Auth.auth().currentUser else { throw AuthRepositoryError.missingUser }
        return user
    }

    private func reauthenticate(password: String) async throws -> User {
        let user = try requireUser()
        guard let email = user.email else { throw AuthRepositoryError.missingUser }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await mapped { try await user.reauthenticate(with: credential).user }
    }

    /// Выполняет запрос к Firebase Auth и переводит его ошибки в доменные.
    private func mapped<Value>(_ operation: () async throws -> Value) async throws -> Value {
        do {
            return try await operation()
        } catch {
            throw FirebaseAuthErrorMapper.map(error)
        }
    }

    private func session(for user: User) -> AuthSession {
        user.isEmailVerified ? .verified : .awaitingEmailVerification(user.email ?? "")
    }

    /// Письма Firebase отправляются на языке приложения.
    private func configureLanguage() {
        Auth.auth().languageCode = Bundle.main.preferredLocalizations.first ?? "en"
    }
}

/// `fetchSignInMethods` помечен в Firebase как deprecated без замены. Вызов через протокол
/// убирает предупреждение; ограничения метода описаны у `isEmailRegistered(_:)`.
private protocol SignInMethodsFetching {
    func fetchSignInMethods(forEmail email: String) async throws -> [String]
}

extension Auth: SignInMethodsFetching {}
