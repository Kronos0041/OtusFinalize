#if DEBUG
import Foundation

/// Сессия в памяти: вход, регистрация, подтверждение почты и выход меняют её и сообщают подписчикам,
/// как это делает Firebase. Так весь путь авторизации проходится в превью без сети.
final class MockAuthRepository: AuthRepositoryProtocol {
    private(set) var session: AuthSession {
        didSet { handlers.forEach { $0(session) } }
    }
    private var handlers: [(AuthSession) -> Void] = []

    var currentUserID: String? { session == .signedOut ? nil : PreviewData.ownerID }

    init(session: AuthSession) {
        self.session = session
    }

    /// Зарегистрированным считается только email из `PreviewData.profile`.
    func isEmailRegistered(_ email: String) async throws -> Bool { email == PreviewData.profile.email }
    func signIn(email: String, password: String) async throws { session = .verified }
    func register(email: String, password: String) async throws { session = .awaitingEmailVerification(email) }
    func sendEmailVerification() async throws {}
    func sendPasswordReset(email: String) async throws {}
    /// Считаем, что письмо уже подтвердили.
    func refreshEmailVerification() async throws -> Bool { true }
    func signOut() throws { session = .signedOut }

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        handlers.append(handler)
        handler(session)
        return ObservationToken {}
    }
}
#endif
