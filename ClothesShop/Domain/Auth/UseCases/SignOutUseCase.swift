struct SignOutUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func signOut() throws {
        try repository.signOut()
    }
}
