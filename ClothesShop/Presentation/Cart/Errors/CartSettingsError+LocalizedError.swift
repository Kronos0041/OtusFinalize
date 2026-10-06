import Foundation

extension CartSettingsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingSettings: return SwiftGen.Cart.Error.missingSettings
        case .invalidMaximumQuantity: return SwiftGen.Cart.Error.invalidSettings
        }
    }
}
