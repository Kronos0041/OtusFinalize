#if DEBUG
import Foundation

/// Ответ mock-репозитория в SwiftUI Preview.
///
/// Через него превью задаёт состояние экрана, не трогая ViewModel:
/// данные → контент или «пусто», ошибка → экран ошибки, `loading` → бесконечная загрузка.
/// Это не замена `ViewMode`: `MockResponse` — то, что вернул репозиторий (слой Data),
/// а `ViewMode` из него строит сама ViewModel. Так превью проверяет настоящую логику ViewModel.
enum MockResponse<Value> {
    case success(Value)
    case failure(Error)
    /// Запрос не завершается: экран остаётся в состоянии загрузки.
    case loading

    func value() async throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        case .loading:
            while true {
                try await Task.sleep(for: .seconds(3600))
            }
        }
    }
}
#endif
