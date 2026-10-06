protocol ConnectivityRepositoryProtocol {
    var isConnected: Bool { get }
    func observe(_ handler: @escaping (Bool) -> Void) -> ObservationToken
}
