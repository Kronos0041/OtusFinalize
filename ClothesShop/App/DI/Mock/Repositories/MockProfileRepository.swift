#if DEBUG
import Foundation

final class MockProfileRepository: ProfileRepositoryProtocol {
    let currentProfile: UserProfile
    private let response: MockResponse<UserProfile>

    init(response: MockResponse<UserProfile>) {
        self.response = response
        if case .success(let profile) = response {
            currentProfile = profile
        } else {
            currentProfile = UserProfile(email: "")
        }
    }

    func refreshProfile() async throws -> UserProfile { try await response.value() }
    func changePassword(currentPassword: String, newPassword: String) async throws {}
    func changeEmail(to email: String, currentPassword: String) async throws {}
}
#endif
