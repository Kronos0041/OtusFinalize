/// Запрос не дошёл до сервера или ответ не получен.
/// Infrastructure переводит в неё технические ошибки (URLSession, Firestore, Firebase Auth),
/// поэтому Presentation отличает проблемы связи от прочих ошибок, не зная деталей Firebase.
enum ConnectivityError: Error, Equatable {
    /// На устройстве нет сети или соединение оборвалось.
    case offline
    /// Сеть есть, но сервер не ответил вовремя или к нему не удалось подключиться.
    case serverUnavailable
}
