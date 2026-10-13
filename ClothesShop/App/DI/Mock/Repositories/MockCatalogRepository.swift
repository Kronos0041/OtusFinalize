#if DEBUG
import Foundation

final class MockCatalogRepository: CatalogRepositoryProtocol {
    private let response: MockResponse<Catalog>

    init(response: MockResponse<Catalog>) {
        self.response = response
    }

    func fetchCatalog() async throws -> Catalog { try await response.value() }
}
#endif
