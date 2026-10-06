struct ObserveConnectivityUseCase {
    private let repository: ConnectivityRepositoryProtocol

    init(repository: ConnectivityRepositoryProtocol) { self.repository = repository }

    var isConnected: Bool { repository.isConnected }

    func execute(_ handler: @escaping (Bool) -> Void) -> ObservationToken {
        repository.observe(handler)
    }
}
