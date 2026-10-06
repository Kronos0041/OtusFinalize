protocol AuthRemoteDataSourceProtocol {
    var currentUserID: String? { get }
    var session: AuthSession { get }
    var currentProfile: UserProfile { get }

    func signIn(email: String, password: String,
                completion: @escaping (Result<Void, Error>) -> Void)
    func register(email: String, password: String,
                  completion: @escaping (Result<Void, Error>) -> Void)
    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void)
    func refreshEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void)
    func refreshProfile(completion: @escaping (Result<UserProfile, Error>) -> Void)
    func changePassword(currentPassword: String, newPassword: String,
                        completion: @escaping (Result<Void, Error>) -> Void)
    func changeEmail(to email: String, currentPassword: String,
                     completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() throws
    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken
}
