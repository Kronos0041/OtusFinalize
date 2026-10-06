import Foundation

enum CartSettingsError: LocalizedError {
    case invalidMaximumQuantity

    var errorDescription: String? {
        "Настройка maximumCartItemQuantity должна быть целым числом от 1 до 999."
    }
}
