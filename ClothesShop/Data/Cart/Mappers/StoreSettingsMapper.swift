enum StoreSettingsMapper {
    static func map(_ dto: StoreSettingsDTO) -> StoreSettings {
        let defaults = StoreSettings.default
        return StoreSettings(
            maximumCartItemQuantity: dto.maximumCartItemQuantity,
            imageLoadMaxAttempts: dto.imageLoadMaxAttempts ?? defaults.imageLoadMaxAttempts,
            imageMemoryCacheCapacityMB: dto.imageMemoryCacheCapacityMB ?? defaults.imageMemoryCacheCapacityMB,
            imageDiskCacheCapacityMB: dto.imageDiskCacheCapacityMB ?? defaults.imageDiskCacheCapacityMB
        )
    }
}
