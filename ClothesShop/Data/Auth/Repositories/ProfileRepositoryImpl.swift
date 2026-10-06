final class ProfileRepositoryImpl: ProfileRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSourceProtocol

    init(remoteDataSource: AuthRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    var currentProfile: UserProfile { remoteDataSource.currentProfile }

    func refreshProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        remoteDataSource.refreshProfile(completion: completion)
    }

    func changePassword(currentPassword: String, newPassword: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        remoteDataSource.changePassword(currentPassword: currentPassword,
                                        newPassword: newPassword,
                                        completion: completion)
    }

    func changeEmail(to email: String, currentPassword: String,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        remoteDataSource.changeEmail(to: email, currentPassword: currentPassword,
                                     completion: completion)
    }
}
