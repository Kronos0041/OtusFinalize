final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSourceProtocol

    init(remoteDataSource: AuthRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    var currentUserID: String? { remoteDataSource.currentUserID }
    var session: AuthSession { remoteDataSource.session }

    func isEmailRegistered(_ email: String) async throws -> Bool {
        try await remoteDataSource.isEmailRegistered(email)
    }

    func signIn(email: String, password: String) async throws {
        try await remoteDataSource.signIn(email: email, password: password)
    }

    func register(email: String, password: String) async throws {
        try await remoteDataSource.register(email: email, password: password)
    }

    func sendEmailVerification() async throws {
        try await remoteDataSource.sendEmailVerification()
    }

    func sendPasswordReset(email: String) async throws {
        try await remoteDataSource.sendPasswordReset(email: email)
    }

    func refreshEmailVerification() async throws -> Bool {
        try await remoteDataSource.refreshEmailVerification()
    }

    func signOut() throws {
        try remoteDataSource.signOut()
    }

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        remoteDataSource.observeSession(handler)
    }
}
