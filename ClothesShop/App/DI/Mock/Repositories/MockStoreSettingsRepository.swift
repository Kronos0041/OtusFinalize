#if DEBUG
import Foundation

final class MockStoreSettingsRepository: StoreSettingsRepositoryProtocol {
    private let response: MockResponse<StoreSettings>

    init(response: MockResponse<StoreSettings>) {
        self.response = response
    }

    func fetchSettings() async throws -> StoreSettings { try await response.value() }
}
#endif
