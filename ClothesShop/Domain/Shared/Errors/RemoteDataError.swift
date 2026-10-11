/// Сервер ответил, но запрос не выполнен.
/// Infrastructure переводит в неё коды ошибок Firestore, чтобы Presentation
/// не показывала пользователю технические тексты Firebase.
enum RemoteDataError: Error, Equatable {
    /// Нет действующей авторизации (Firestore `unauthenticated`): нужно войти заново.
    case unauthorized
    /// Правила безопасности запрещают операцию (Firestore `permissionDenied`).
    case permissionDenied
    /// Документ не найден (Firestore `notFound`).
    case notFound
    /// Превышена квота или лимит запросов (Firestore `resourceExhausted`).
    case quotaExceeded
    /// Данные повреждены или не соответствуют ожидаемой схеме.
    case invalidData
    /// Прочие ошибки сервера, повторять которые бессмысленно без изменений.
    case unexpected
}
