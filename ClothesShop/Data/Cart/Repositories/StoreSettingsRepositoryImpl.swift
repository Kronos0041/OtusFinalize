final class StoreSettingsRepositoryImpl: StoreSettingsRepositoryProtocol {
    private let remoteDataSource: StoreSettingsRemoteDataSourceProtocol

    init(remoteDataSource: StoreSettingsRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchSettings() async throws -> StoreSettings {
        StoreSettingsMapper.map(try await remoteDataSource.fetchSettings())
    }
}
