protocol ProfileRepositoryProtocol {
    var currentProfile: UserProfile { get }

    func refreshProfile() async throws -> UserProfile
    func changePassword(currentPassword: String, newPassword: String) async throws
    func changeEmail(to email: String, currentPassword: String) async throws
}
