final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSourceProtocol

    init(remoteDataSource: AuthRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    var currentUserID: String? { remoteDataSource.currentUserID }
    var session: AuthSession { remoteDataSource.session }

    func signIn(email: String, password: String, completion: @escaping Completion) {
        remoteDataSource.signIn(email: email, password: password, completion: completion)
    }

    func register(email: String, password: String, completion: @escaping Completion) {
        remoteDataSource.register(email: email, password: password, completion: completion)
    }

    func sendEmailVerification(completion: @escaping Completion) {
        remoteDataSource.sendEmailVerification(completion: completion)
    }

    func refreshEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void) {
        remoteDataSource.refreshEmailVerification(completion: completion)
    }

    func signOut() throws { try remoteDataSource.signOut() }

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        remoteDataSource.observeSession(handler)
    }
}
