protocol StoreSettingsRemoteDataSourceProtocol {
    func fetchSettings(completion: @escaping (Result<StoreSettingsDTO, Error>) -> Void)
}
