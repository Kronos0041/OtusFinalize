struct ObserveConnectivityUseCase {
    private let repository: ConnectivityRepositoryProtocol

    init(repository: ConnectivityRepositoryProtocol) {
        self.repository = repository
    }

    var isConnected: Bool { repository.isConnected }

    func execute() -> AsyncStream<Bool> {
        repository.updates()
    }
}
