protocol ProfileRepositoryProtocol {
    var currentProfile: UserProfile { get }

    func refreshProfile(completion: @escaping (Result<UserProfile, Error>) -> Void)
    func changePassword(currentPassword: String, newPassword: String,
                        completion: @escaping (Result<Void, Error>) -> Void)
    func changeEmail(to email: String, currentPassword: String,
                     completion: @escaping (Result<Void, Error>) -> Void)
}
