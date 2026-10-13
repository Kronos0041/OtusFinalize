#if DEBUG
import Foundation

struct MockImageCacheRepository: ImageCacheRepositoryProtocol {
    func updateCapacity(memoryCapacityMB: Int, diskCapacityMB: Int) {}
}
#endif
