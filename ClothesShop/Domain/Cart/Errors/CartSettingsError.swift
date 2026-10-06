/// Ошибки настроек магазина (`settings/store`).
/// Тексты для пользователя задаёт Presentation (`CartSettingsError+LocalizedError`).
enum CartSettingsError: Error, Equatable {
    /// Документ настроек отсутствует.
    case missingSettings
    /// `maximumCartItemQuantity` вне допустимого диапазона.
    case invalidMaximumQuantity
}
