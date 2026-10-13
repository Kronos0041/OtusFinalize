struct ObserveAuthSessionUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    var currentSession: AuthSession { repository.session }

    func observeSession(_ handler: @escaping (AuthSession) -> Void) -> ObservationToken {
        repository.observeSession(handler)
    }
}
