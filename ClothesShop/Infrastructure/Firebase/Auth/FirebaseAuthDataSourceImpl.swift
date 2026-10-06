import FirebaseAuth
import Foundation

final class FirebaseAuthDataSourceImpl: AuthRemoteDataSourceProtocol {
    var currentUserID: String? { Auth.auth().currentUser?.uid }
    var currentProfile: UserProfile { UserProfile(email: Auth.auth().currentUser?.email ?? "") }

    var session: AuthSession {
        guard let user = Auth.auth().currentUser else { return .signedOut }
        return session(for: user)
    }

    func signIn(email: String, password: String,
                completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error { completion(.failure(FirebaseAuthErrorMapper.map(error))) }
            else if result != nil { completion(.success(())) }
            else { completion(.failure(AuthRepositoryError.unexpected)) }
        }
    }

    func register(email: String, password: String,
                  completion: @escaping (Result<Void, Error>) -> Void) {
        configureLanguage()
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error { completion(.failure(FirebaseAuthErrorMapper.map(error))); return }
            guard let user = result?.user else {
                completion(.failure(AuthRepositoryError.missingUser)); return
            }
            user.sendEmailVerification { error in
                completion(error.map { .failure(FirebaseAuthErrorMapper.map($0)) } ?? .success(()))
            }
        }
    }

    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(AuthRepositoryError.missingUser)); return
        }
        configureLanguage()
        user.sendEmailVerification { error in
            completion(error.map { .failure(FirebaseAuthErrorMapper.map($0)) } ?? .success(()))
        }
    }

    func refreshEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(AuthRepositoryError.missingUser)); return
        }
        user.reload { error in
            if let error { completion(.failure(FirebaseAuthErrorMapper.map(error))); return }
            guard user.isEmailVerified else { completion(.success(false)); return }
            user.getIDTokenForcingRefresh(true) { _, error in
                completion(error.map { .failure(FirebaseAuthErrorMapper.map($0)) } ?? .success(true))
            }
        }
    }

    func refreshProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(AuthRepositoryError.missingUser)); return
        }
        user.reload { [weak self] error in
            if let error { completion(.failure(FirebaseAuthErrorMapper.map(error))); return }
            user.getIDTokenForcingRefresh(true) { _, error in
                if let error { completion(.failure(FirebaseAuthErrorMapper.map(error))) }
                else { completion(.success(self?.currentProfile ?? UserProfile(email: ""))) }
            }
        }
    }

    func changePassword(currentPassword: String, newPassword: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        reauthenticate(password: currentPassword) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let user):
                user.updatePassword(to: newPassword) { error in
                    completion(error.map { .failure(FirebaseAuthErrorMapper.map($0)) } ?? .success(()))
                }
            }
        }
    }

    func changeEmail(to email: String, currentPassword: String,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        reauthenticate(password: currentPassword) { [weak self] result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let user):
                self?.configureLanguage()
                user.sendEmailVerification(beforeUpdatingEmail: email) { error in
                    completion(error.map { .failure(FirebaseAuthErrorMapper.map($0)) } ?? .success(()))
                }
            }
        }
    }

    func signOut() throws {
        do { try Auth.auth().signOut() }
        catch { throw FirebaseAuthErrorMapper.map(error) }
    }

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        let handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            handler(user.map(self.session(for:)) ?? .signedOut)
        }
        return ObservationToken { Auth.auth().removeStateDidChangeListener(handle) }
    }

    private func reauthenticate(password: String,
                                completion: @escaping (Result<User, Error>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(.failure(AuthRepositoryError.missingUser)); return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { result, error in
            if let error { completion(.failure(FirebaseAuthErrorMapper.map(error))) }
            else if let user = result?.user { completion(.success(user)) }
            else { completion(.failure(AuthRepositoryError.missingUser)) }
        }
    }

    private func session(for user: User) -> AuthSession {
        user.isEmailVerified ? .verified : .awaitingEmailVerification(user.email ?? "")
    }

    private func configureLanguage() {
        Auth.auth().languageCode = Bundle.main.preferredLocalizations.first ?? "en"
    }
}
