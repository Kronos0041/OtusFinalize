import SwiftUI

/// Число повторов загрузки картинки для `RemoteImageView`. Задаётся из `settings/store` в `MainTabView`.
struct ImageLoadMaxAttemptsKey: EnvironmentKey {
    static let defaultValue = StoreSettings.default.imageLoadMaxAttempts
}
