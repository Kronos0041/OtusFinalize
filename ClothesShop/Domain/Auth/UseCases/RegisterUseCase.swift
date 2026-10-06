struct RegisterUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String,
                 completion: @escaping AuthRepositoryProtocol.Completion) {
        repository.register(email: email, password: password, completion: completion)
    }
}
