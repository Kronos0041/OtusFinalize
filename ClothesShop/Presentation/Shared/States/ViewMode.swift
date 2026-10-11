enum ViewMode<Content> {
    case loading
    case content(Content)
    case empty
    case noInternet
    case error(String)

    var content: Content? {
        if case .content(let content) = self { return content }
        return nil
    }

    /// Единое правило разбора ответа: пусто / контент / нет сети / ошибка.
    static func make(from result: Result<Content, Error>,
                     isEmpty: (Content) -> Bool) -> ViewMode {
        switch result {
        case .success(let value): return isEmpty(value) ? .empty : .content(value)
        case .failure(let error):
            return error as? ConnectivityError == .offline ? .noInternet : .error(error.localizedDescription)
        }
    }
}
