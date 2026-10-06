protocol ConnectivityRepositoryProtocol {
    /// Есть ли сейчас подключение к сети.
    var isConnected: Bool { get }
    /// Поток изменений доступности сети: `true` — связь появилась, `false` — пропала.
    func updates() -> AsyncStream<Bool>
}
