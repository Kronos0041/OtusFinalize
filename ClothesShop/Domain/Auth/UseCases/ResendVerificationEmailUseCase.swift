struct ResendVerificationEmailUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping AuthRepositoryProtocol.Completion) {
        repository.sendEmailVerification(completion: completion)
    }
}
