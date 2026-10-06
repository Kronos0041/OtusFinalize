struct ChangeEmailUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) { self.repository = repository }

    func execute(email: String, currentPassword: String,
                 completion: @escaping (Result<Void, Error>) -> Void) {
        repository.changeEmail(to: email, currentPassword: currentPassword, completion: completion)
    }
}
