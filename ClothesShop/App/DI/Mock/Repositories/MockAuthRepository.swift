#if DEBUG
import Foundation

final class MockAuthRepository: AuthRepositoryProtocol {
    private(set) var session: AuthSession

    var currentUserID: String? { session == .signedOut ? nil : PreviewData.ownerID }

    init(session: AuthSession) {
        self.session = session
    }

    func signIn(email: String, password: String) async throws {}
    func register(email: String, password: String) async throws {}
    func sendEmailVerification() async throws {}
    func refreshEmailVerification() async throws -> Bool { session == .verified }
    func signOut() throws {}

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        handler(session)
        return ObservationToken {}
    }
}
#endif
