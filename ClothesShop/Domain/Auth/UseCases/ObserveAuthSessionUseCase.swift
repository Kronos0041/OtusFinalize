struct ObserveAuthSessionUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    var currentSession: AuthSession { repository.session }

    func execute(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        repository.observeSession(handler)
    }
}
