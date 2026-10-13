struct ResendVerificationEmailUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func resendVerificationEmail() async throws {
        try await repository.sendEmailVerification()
    }
}
