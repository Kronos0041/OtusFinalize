protocol AuthRepositoryProtocol {
    var currentUserID: String? { get }
    var session: AuthSession { get }

    /// Есть ли аккаунт с этим email.
    func isEmailRegistered(_ email: String) async throws -> Bool
    func signIn(email: String, password: String) async throws
    func register(email: String, password: String) async throws
    func sendEmailVerification() async throws
    func sendPasswordReset(email: String) async throws
    /// Обновляет пользователя и возвращает, подтверждён ли email.
    func refreshEmailVerification() async throws -> Bool
    func signOut() throws
    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken
}
