struct ChangePasswordUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        try await repository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
}
