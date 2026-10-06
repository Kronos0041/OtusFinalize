protocol StoreSettingsRepositoryProtocol {
    func fetchSettings() async throws -> StoreSettings
}
