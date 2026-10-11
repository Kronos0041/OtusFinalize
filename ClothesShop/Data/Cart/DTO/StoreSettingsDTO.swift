/// Документ `settings/store`. Поля картинок необязательны: старый документ без них тоже читается.
struct StoreSettingsDTO: Decodable {
    let maximumCartItemQuantity: Int
    let imageLoadMaxAttempts: Int?
    let imageMemoryCacheCapacityMB: Int?
    let imageDiskCacheCapacityMB: Int?
}
