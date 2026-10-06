/// Настройки магазина из документа Firestore `settings/store`.
struct StoreSettings: Equatable {
    /// Значения, которые действуют до загрузки настроек и для отсутствующих полей документа.
    static let `default` = StoreSettings(maximumCartItemQuantity: 99,
                                         imageLoadMaxAttempts: 3,
                                         imageMemoryCacheCapacityMB: 32,
                                         imageDiskCacheCapacityMB: 128)

    /// Максимальное количество единиц одной позиции корзины.
    let maximumCartItemQuantity: Int
    /// Сколько раз повторять загрузку картинки товара после неудачи.
    let imageLoadMaxAttempts: Int
    /// Размер кэша картинок в оперативной памяти, МБ.
    let imageMemoryCacheCapacityMB: Int
    /// Размер кэша картинок на диске, МБ.
    let imageDiskCacheCapacityMB: Int
}
