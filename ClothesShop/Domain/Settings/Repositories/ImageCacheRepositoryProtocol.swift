/// Кэш загруженных картинок товаров.
protocol ImageCacheRepositoryProtocol {
    func updateCapacity(memoryCapacityMB: Int, diskCapacityMB: Int)
}
