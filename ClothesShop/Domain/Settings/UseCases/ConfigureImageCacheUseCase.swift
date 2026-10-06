/// Применяет размеры кэша картинок из настроек магазина.
struct ConfigureImageCacheUseCase {
    private let repository: ImageCacheRepositoryProtocol

    init(repository: ImageCacheRepositoryProtocol) {
        self.repository = repository
    }

    func execute(settings: StoreSettings) {
        repository.updateCapacity(memoryCapacityMB: settings.imageMemoryCacheCapacityMB,
                                  diskCapacityMB: settings.imageDiskCacheCapacityMB)
    }
}
