struct SignInUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws {
        try await repository.signIn(email: email, password: password)
    }
}
