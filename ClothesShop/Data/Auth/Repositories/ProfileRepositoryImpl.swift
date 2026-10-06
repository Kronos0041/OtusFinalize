final class ProfileRepositoryImpl: ProfileRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSourceProtocol

    init(remoteDataSource: AuthRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    var currentProfile: UserProfile { remoteDataSource.currentProfile }

    func refreshProfile() async throws -> UserProfile {
        try await remoteDataSource.refreshProfile()
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        try await remoteDataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword)
    }

    func changeEmail(to email: String, currentPassword: String) async throws {
        try await remoteDataSource.changeEmail(to: email, currentPassword: currentPassword)
    }
}
