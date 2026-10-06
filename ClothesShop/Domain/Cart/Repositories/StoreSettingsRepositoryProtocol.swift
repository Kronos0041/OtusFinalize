protocol StoreSettingsRepositoryProtocol {
    func fetchSettings(completion: @escaping (Result<StoreSettings, Error>) -> Void)
}
