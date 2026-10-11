import Foundation
import Observation

/// Стек навигации одной вкладки. Вкладка владеет роутером и передаёт его вложенным экранам
/// через Environment, чтобы глубоко вложенная ячейка могла открыть экран без цепочки замыканий.
@MainActor
@Observable
final class Router<Route: Hashable> {
    private(set) var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    /// Стек меняет `NavigationStack` (кнопка «Назад», свайп).
    func updatePath(_ path: [Route]) {
        self.path = path
    }
}
