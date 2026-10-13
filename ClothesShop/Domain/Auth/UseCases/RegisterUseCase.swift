struct RegisterUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func register(email: String, password: String) async throws {
        try await repository.register(email: email, password: password)
    }
}
