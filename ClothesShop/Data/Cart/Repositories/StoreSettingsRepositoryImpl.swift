final class StoreSettingsRepositoryImpl: StoreSettingsRepositoryProtocol {
    private let remoteDataSource: StoreSettingsRemoteDataSourceProtocol

    init(remoteDataSource: StoreSettingsRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchSettings(completion: @escaping (Result<StoreSettings, Error>) -> Void) {
        remoteDataSource.fetchSettings { completion($0.map(StoreSettingsMapper.map)) }
    }
}
