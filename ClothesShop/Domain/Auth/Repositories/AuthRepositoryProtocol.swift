protocol AuthRepositoryProtocol {
    typealias Completion = (Result<Void, Error>) -> Void

    var currentUserID: String? { get }
    var session: AuthSession { get }

    func signIn(email: String, password: String, completion: @escaping Completion)
    func register(email: String, password: String, completion: @escaping Completion)
    func sendEmailVerification(completion: @escaping Completion)
    func refreshEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void)
    func signOut() throws
    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken
}
