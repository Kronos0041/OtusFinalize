/// Операция не выполнена из-за отсутствия связи с сервером.
/// Infrastructure переводит в неё технические ошибки (URLSession, Firestore, Firebase Auth),
/// поэтому Presentation отличает «нет сети» от прочих ошибок, не зная деталей Firebase.
enum ConnectivityError: Error, Equatable {
    case offline
}
