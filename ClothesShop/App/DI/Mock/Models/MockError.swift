#if DEBUG
import Foundation

/// Ошибка для превью экрана ошибки. Текст попадает в `ViewMode.error`.
struct MockError: LocalizedError {
    let errorDescription: String?

    init(_ message: String) {
        errorDescription = message
    }
}
#endif
