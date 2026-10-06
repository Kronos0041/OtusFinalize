/// Загружает настройки магазина и проверяет их бизнес-правила.
struct GetStoreSettingsUseCase {
    /// Допустимый лимит одной позиции корзины. Тот же диапазон проверяют seed-скрипт и правила Firestore.
    static let allowedMaximumQuantity = 1...999
    static let allowedImageLoadAttempts = 0...10
    static let allowedImageMemoryCacheMB = 1...512
    static let allowedImageDiskCacheMB = 1...2048

    private let repository: StoreSettingsRepositoryProtocol

    init(repository: StoreSettingsRepositoryProtocol) {
        self.repository = repository
    }

    /// Ошибка в лимите корзины прерывает загрузку: без него нельзя безопасно менять корзину.
    /// Некорректные настройки картинок заменяются значениями по умолчанию — они не критичны.
    func execute() async throws -> StoreSettings {
        let settings = try await repository.fetchSettings()
        guard Self.allowedMaximumQuantity.contains(settings.maximumCartItemQuantity) else {
            throw CartSettingsError.invalidMaximumQuantity
        }
        let defaults = StoreSettings.default
        return StoreSettings(
            maximumCartItemQuantity: settings.maximumCartItemQuantity,
            imageLoadMaxAttempts: Self.value(settings.imageLoadMaxAttempts,
                                             in: Self.allowedImageLoadAttempts,
                                             default: defaults.imageLoadMaxAttempts),
            imageMemoryCacheCapacityMB: Self.value(settings.imageMemoryCacheCapacityMB,
                                                   in: Self.allowedImageMemoryCacheMB,
                                                   default: defaults.imageMemoryCacheCapacityMB),
            imageDiskCacheCapacityMB: Self.value(settings.imageDiskCacheCapacityMB,
                                                 in: Self.allowedImageDiskCacheMB,
                                                 default: defaults.imageDiskCacheCapacityMB)
        )
    }

    private static func value(_ value: Int, in range: ClosedRange<Int>, default fallback: Int) -> Int {
        range.contains(value) ? value : fallback
    }
}
