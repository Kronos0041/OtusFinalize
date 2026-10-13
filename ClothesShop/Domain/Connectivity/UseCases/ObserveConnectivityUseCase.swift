struct ObserveConnectivityUseCase {
    private let repository: ConnectivityRepositoryProtocol

    init(repository: ConnectivityRepositoryProtocol) {
        self.repository = repository
    }

    var isConnected: Bool { repository.isConnected }

    func observeConnectivity() -> AsyncStream<Bool> {
        repository.updates()
    }
}
