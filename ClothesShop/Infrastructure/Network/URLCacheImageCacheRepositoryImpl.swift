import Foundation

/// Кэш картинок на основе общего `URLCache`: его использует `AsyncImage` внутри `RemoteImageView`.
/// При создании ставит кэш с начальными размерами; размеры из настроек применяются на лету.
final class URLCacheImageCacheRepositoryImpl: ImageCacheRepositoryProtocol {
    private static let diskPath = "product-images"
    private static let bytesInMegabyte = 1024 * 1024

    init(memoryCapacityMB: Int, diskCapacityMB: Int) {
        URLCache.shared = URLCache(memoryCapacity: memoryCapacityMB * Self.bytesInMegabyte,
                                   diskCapacity: diskCapacityMB * Self.bytesInMegabyte,
                                   diskPath: Self.diskPath)
    }

    func updateCapacity(memoryCapacityMB: Int, diskCapacityMB: Int) {
        URLCache.shared.memoryCapacity = memoryCapacityMB * Self.bytesInMegabyte
        URLCache.shared.diskCapacity = diskCapacityMB * Self.bytesInMegabyte
    }
}
