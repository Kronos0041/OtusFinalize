enum StoreSettingsMapper {
    static func map(_ dto: StoreSettingsDTO) -> StoreSettings {
        StoreSettings(maximumCartItemQuantity: dto.maximumCartItemQuantity)
    }
}
