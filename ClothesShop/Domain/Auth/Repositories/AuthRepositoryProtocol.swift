protocol AuthRepositoryProtocol {
    var currentUserID: String? { get }
    var session: AuthSession { get }

    func signIn(email: String, password: String) async throws
    func register(email: String, password: String) async throws
    func sendEmailVerification() async throws
    /// Обновляет пользователя и возвращает, подтверждён ли email.
    func refreshEmailVerification() async throws -> Bool
    func signOut() throws
    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken
}
