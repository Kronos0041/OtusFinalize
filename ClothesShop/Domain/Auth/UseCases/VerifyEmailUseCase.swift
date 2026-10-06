struct VerifyEmailUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<Bool, Error>) -> Void) {
        repository.refreshEmailVerification(completion: completion)
    }
}
