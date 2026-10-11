struct VerifyEmailUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    /// Возвращает `true`, если email уже подтверждён.
    func execute() async throws -> Bool {
        try await repository.refreshEmailVerification()
    }
}
