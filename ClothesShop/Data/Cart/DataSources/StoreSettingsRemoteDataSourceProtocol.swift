protocol StoreSettingsRemoteDataSourceProtocol {
    func fetchSettings() async throws -> StoreSettingsDTO
}
