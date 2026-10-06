import Foundation

final class UserDefaultsNotificationReadStateDataSourceImpl: NotificationReadStateDataSourceProtocol {
    private let defaults: UserDefaults
    private let key = "notifications.seenIds"

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func readNotificationIDs() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    func saveReadNotificationIDs(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}
