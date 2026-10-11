import SwiftUI

extension EnvironmentValues {
    /// Число повторов загрузки картинки для `RemoteImageView`. Задаётся из `settings/store` в `MainTabView`.
    @Entry var imageLoadMaxAttempts = StoreSettings.default.imageLoadMaxAttempts
}
