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

    /// Возврат на предыдущий экран (кнопка «Назад» в собственной шапке экрана).
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Стек меняет `NavigationStack` (кнопка «Назад», свайп).
    func updatePath(_ path: [Route]) {
        self.path = path
    }
}
