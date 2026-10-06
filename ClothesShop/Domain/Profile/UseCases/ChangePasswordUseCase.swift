struct ChangePasswordUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) { self.repository = repository }

    func execute(currentPassword: String, newPassword: String,
                 completion: @escaping (Result<Void, Error>) -> Void) {
        repository.changePassword(currentPassword: currentPassword, newPassword: newPassword,
                                  completion: completion)
    }
}
