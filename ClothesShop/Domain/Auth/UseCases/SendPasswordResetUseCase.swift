struct SendPasswordResetUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func sendPasswordReset(email: String) async throws {
        try await repository.sendPasswordReset(email: email)
    }
}
