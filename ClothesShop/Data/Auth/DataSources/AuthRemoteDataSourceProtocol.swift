protocol AuthRemoteDataSourceProtocol {
    var currentUserID: String? { get }
    var session: AuthSession { get }
    var currentProfile: UserProfile { get }

    func isEmailRegistered(_ email: String) async throws -> Bool
    func signIn(email: String, password: String) async throws
    func register(email: String, password: String) async throws
    func sendEmailVerification() async throws
    func sendPasswordReset(email: String) async throws
    func refreshEmailVerification() async throws -> Bool
    func refreshProfile() async throws -> UserProfile
    func changePassword(currentPassword: String, newPassword: String) async throws
    func changeEmail(to email: String, currentPassword: String) async throws
    func signOut() throws
    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken
}
