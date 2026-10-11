struct ChangePasswordUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(currentPassword: String, newPassword: String) async throws {
        try await repository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
}
