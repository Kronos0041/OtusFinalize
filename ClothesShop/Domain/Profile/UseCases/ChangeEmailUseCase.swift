struct ChangeEmailUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func changeEmail(to email: String, currentPassword: String) async throws {
        try await repository.changeEmail(to: email, currentPassword: currentPassword)
    }
}
