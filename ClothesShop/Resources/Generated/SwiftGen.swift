// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum SwiftGen {
  internal enum Auth {
    /// Sign in
    internal static let authorization = SwiftGen.tr("Localizable", "auth.authorization", fallback: "Sign in")
    /// Password
    internal static let password = SwiftGen.tr("Localizable", "auth.password", fallback: "Password")
    /// Repeat password
    internal static let repeatPassword = SwiftGen.tr("Localizable", "auth.repeatPassword", fallback: "Repeat password")
    /// Sign in
    internal static let signIn = SwiftGen.tr("Localizable", "auth.signIn", fallback: "Sign in")
    /// Sign out
    internal static let signOut = SwiftGen.tr("Localizable", "auth.signOut", fallback: "Sign out")
    /// Sign up
    internal static let signUp = SwiftGen.tr("Localizable", "auth.signUp", fallback: "Sign up")
    internal enum Error {
      /// This account has been disabled.
      internal static let accountDisabled = SwiftGen.tr("Localizable", "auth.error.accountDisabled", fallback: "This account has been disabled.")
      /// This email is already used by another account.
      internal static let emailInUse = SwiftGen.tr("Localizable", "auth.error.emailInUse", fallback: "This email is already used by another account.")
      /// Incorrect email or password.
      internal static let invalidCredentials = SwiftGen.tr("Localizable", "auth.error.invalidCredentials", fallback: "Incorrect email or password.")
      /// Invalid email
      internal static let invalidEmail = SwiftGen.tr("Localizable", "auth.error.invalidEmail", fallback: "Invalid email")
      /// Passwords don't match
      internal static let passwordMismatch = SwiftGen.tr("Localizable", "auth.error.passwordMismatch", fallback: "Passwords don't match")
      /// Enter your password
      internal static let passwordRequired = SwiftGen.tr("Localizable", "auth.error.passwordRequired", fallback: "Enter your password")
      /// Password must be at least %lld characters long
      internal static func passwordTooShort(_ p1: Int) -> String {
        return SwiftGen.tr("Localizable", "auth.error.passwordTooShort", p1, fallback: "Password must be at least %lld characters long")
      }
      /// Your session has ended. Please sign in again.
      internal static let sessionEnded = SwiftGen.tr("Localizable", "auth.error.sessionEnded", fallback: "Your session has ended. Please sign in again.")
      /// Your session has expired. Sign out and sign in again.
      internal static let sessionExpired = SwiftGen.tr("Localizable", "auth.error.sessionExpired", fallback: "Your session has expired. Sign out and sign in again.")
      /// Too many attempts. Try again later.
      internal static let tooManyRequests = SwiftGen.tr("Localizable", "auth.error.tooManyRequests", fallback: "Too many attempts. Try again later.")
      /// Couldn't complete the request. Please try again later.
      internal static let unexpected = SwiftGen.tr("Localizable", "auth.error.unexpected", fallback: "Couldn't complete the request. Please try again later.")
      /// The password does not meet Firebase security requirements.
      internal static let weakPassword = SwiftGen.tr("Localizable", "auth.error.weakPassword", fallback: "The password does not meet Firebase security requirements.")
      /// Incorrect current password.
      internal static let wrongPassword = SwiftGen.tr("Localizable", "auth.error.wrongPassword", fallback: "Incorrect current password.")
    }
    internal enum Verification {
      /// I've confirmed my email
      internal static let check = SwiftGen.tr("Localizable", "auth.verification.check", fallback: "I've confirmed my email")
      /// We sent an email to %@. Open the link in it, then come back here.
      internal static func instructions(_ p1: Any) -> String {
        return SwiftGen.tr("Localizable", "auth.verification.instructions", String(describing: p1), fallback: "We sent an email to %@. Open the link in it, then come back here.")
      }
      /// Your email isn't confirmed yet. Open the link from the email and try again.
      internal static let notConfirmed = SwiftGen.tr("Localizable", "auth.verification.notConfirmed", fallback: "Your email isn't confirmed yet. Open the link from the email and try again.")
      /// Confirm your address using the link in the email. Resend it if needed.
      internal static let `required` = SwiftGen.tr("Localizable", "auth.verification.required", fallback: "Confirm your address using the link in the email. Resend it if needed.")
      /// Resend email
      internal static let resend = SwiftGen.tr("Localizable", "auth.verification.resend", fallback: "Resend email")
      /// Email sent again. Please also check your spam folder.
      internal static let resent = SwiftGen.tr("Localizable", "auth.verification.resent", fallback: "Email sent again. Please also check your spam folder.")
      /// Couldn't send the email: %@
      internal static func sendFailed(_ p1: Any) -> String {
        return SwiftGen.tr("Localizable", "auth.verification.sendFailed", String(describing: p1), fallback: "Couldn't send the email: %@")
      }
      /// Email sent. Confirm your address using the link in it.
      internal static let sent = SwiftGen.tr("Localizable", "auth.verification.sent", fallback: "Email sent. Confirm your address using the link in it.")
      /// Confirm your email
      internal static let title = SwiftGen.tr("Localizable", "auth.verification.title", fallback: "Confirm your email")
    }
  }
  internal enum Cart {
    /// Added
    internal static let added = SwiftGen.tr("Localizable", "cart.added", fallback: "Added")
    /// Check out
    internal static let checkout = SwiftGen.tr("Localizable", "cart.checkout", fallback: "Check out")
    /// Select a size to add this product to your bag.
    internal static let chooseSize = SwiftGen.tr("Localizable", "cart.chooseSize", fallback: "Select a size to add this product to your bag.")
    /// Confirm demo order
    internal static let confirmDemo = SwiftGen.tr("Localizable", "cart.confirmDemo", fallback: "Confirm demo order")
    /// Continue shopping
    internal static let continueShopping = SwiftGen.tr("Localizable", "cart.continueShopping", fallback: "Continue shopping")
    /// Decrease quantity
    internal static let decrease = SwiftGen.tr("Localizable", "cart.decrease", fallback: "Decrease quantity")
    /// Delete
    internal static let delete = SwiftGen.tr("Localizable", "cart.delete", fallback: "Delete")
    /// This is a demo. No payment will be charged and no order will be sent to the store.
    internal static let demoHint = SwiftGen.tr("Localizable", "cart.demoHint", fallback: "This is a demo. No payment will be charged and no order will be sent to the store.")
    /// Demo order completed
    internal static let demoSuccess = SwiftGen.tr("Localizable", "cart.demoSuccess", fallback: "Demo order completed")
    /// Your bag is empty
    internal static let empty = SwiftGen.tr("Localizable", "cart.empty", fallback: "Your bag is empty")
    /// Add a product from its details page.
    internal static let emptyHint = SwiftGen.tr("Localizable", "cart.emptyHint", fallback: "Add a product from its details page.")
    /// Increase quantity
    internal static let increase = SwiftGen.tr("Localizable", "cart.increase", fallback: "Increase quantity")
    /// %lld pcs · %@
    internal static func lineTotal(_ p1: Int, _ p2: Any) -> String {
      return SwiftGen.tr("Localizable", "cart.lineTotal", p1, String(describing: p2), fallback: "%lld pcs · %@")
    }
    /// You can add up to %lld of each item.
    internal static func quantityLimit(_ p1: Int) -> String {
      return SwiftGen.tr("Localizable", "cart.quantityLimit", p1, fallback: "You can add up to %lld of each item.")
    }
    /// Size: %@
    internal static func size(_ p1: Any) -> String {
      return SwiftGen.tr("Localizable", "cart.size", String(describing: p1), fallback: "Size: %@")
    }
    /// My Bag
    internal static let title = SwiftGen.tr("Localizable", "cart.title", fallback: "My Bag")
    /// Total amount
    internal static let total = SwiftGen.tr("Localizable", "cart.total", fallback: "Total amount")
    /// Couldn't update your bag. Please try again.
    internal static let updateFailed = SwiftGen.tr("Localizable", "cart.updateFailed", fallback: "Couldn't update your bag. Please try again.")
    internal enum Error {
      /// Store settings are invalid: the bag limit must be between 1 and 999.
      internal static let invalidSettings = SwiftGen.tr("Localizable", "cart.error.invalidSettings", fallback: "Store settings are invalid: the bag limit must be between 1 and 999.")
      /// Store settings are unavailable. Please try again later.
      internal static let missingSettings = SwiftGen.tr("Localizable", "cart.error.missingSettings", fallback: "Store settings are unavailable. Please try again later.")
    }
  }
  internal enum Catalog {
    /// All
    internal static let all = SwiftGen.tr("Localizable", "catalog.all", fallback: "All")
    /// The catalog is empty
    internal static let empty = SwiftGen.tr("Localizable", "catalog.empty", fallback: "The catalog is empty")
    /// Home
    internal static let title = SwiftGen.tr("Localizable", "catalog.title", fallback: "Home")
    internal enum Search {
      /// Try a different query or category.
      internal static let changeQuery = SwiftGen.tr("Localizable", "catalog.search.changeQuery", fallback: "Try a different query or category.")
      /// Clear search
      internal static let clear = SwiftGen.tr("Localizable", "catalog.search.clear", fallback: "Clear search")
      /// No products found
      internal static let empty = SwiftGen.tr("Localizable", "catalog.search.empty", fallback: "No products found")
    }
  }
  internal enum Common {
    /// Add
    internal static let add = SwiftGen.tr("Localizable", "common.add", fallback: "Add")
    /// Back
    internal static let back = SwiftGen.tr("Localizable", "common.back", fallback: "Back")
    /// Cancel
    internal static let cancel = SwiftGen.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Close
    internal static let close = SwiftGen.tr("Localizable", "common.close", fallback: "Close")
    /// Email
    internal static let email = SwiftGen.tr("Localizable", "common.email", fallback: "Email")
    /// Nothing here yet
    internal static let empty = SwiftGen.tr("Localizable", "common.empty", fallback: "Nothing here yet")
    /// OK
    internal static let ok = SwiftGen.tr("Localizable", "common.ok", fallback: "OK")
    /// Try again
    internal static let retry = SwiftGen.tr("Localizable", "common.retry", fallback: "Try again")
    /// Search
    internal static let search = SwiftGen.tr("Localizable", "common.search", fallback: "Search")
    /// Share
    internal static let share = SwiftGen.tr("Localizable", "common.share", fallback: "Share")
  }
  internal enum Favorites {
    /// Add to favorites
    internal static let add = SwiftGen.tr("Localizable", "favorites.add", fallback: "Add to favorites")
    /// Clear
    internal static let clear = SwiftGen.tr("Localizable", "favorites.clear", fallback: "Clear")
    /// No favorites yet
    internal static let empty = SwiftGen.tr("Localizable", "favorites.empty", fallback: "No favorites yet")
    /// Tap the heart on a product to add it here.
    internal static let instructions = SwiftGen.tr("Localizable", "favorites.instructions", fallback: "Tap the heart on a product to add it here.")
    /// Remove from favorites
    internal static let remove = SwiftGen.tr("Localizable", "favorites.remove", fallback: "Remove from favorites")
    /// Favorites
    internal static let title = SwiftGen.tr("Localizable", "favorites.title", fallback: "Favorites")
  }
  internal enum Network {
    /// Couldn't load data
    internal static let loadFailed = SwiftGen.tr("Localizable", "network.loadFailed", fallback: "Couldn't load data")
    /// No internet connection
    internal static let offline = SwiftGen.tr("Localizable", "network.offline", fallback: "No internet connection")
    /// Data will load automatically once you're back online.
    internal static let reconnect = SwiftGen.tr("Localizable", "network.reconnect", fallback: "Data will load automatically once you're back online.")
    /// Server is not responding. Please try again later.
    internal static let serverUnavailable = SwiftGen.tr("Localizable", "network.serverUnavailable", fallback: "Server is not responding. Please try again later.")
    internal enum Error {
      /// Received invalid data from the server.
      internal static let invalidData = SwiftGen.tr("Localizable", "network.error.invalidData", fallback: "Received invalid data from the server.")
      /// The requested data wasn't found.
      internal static let notFound = SwiftGen.tr("Localizable", "network.error.notFound", fallback: "The requested data wasn't found.")
      /// You don't have access to this data.
      internal static let permissionDenied = SwiftGen.tr("Localizable", "network.error.permissionDenied", fallback: "You don't have access to this data.")
      /// Too many requests. Please try again later.
      internal static let quotaExceeded = SwiftGen.tr("Localizable", "network.error.quotaExceeded", fallback: "Too many requests. Please try again later.")
      /// Your session has expired. Please sign in again.
      internal static let unauthorized = SwiftGen.tr("Localizable", "network.error.unauthorized", fallback: "Your session has expired. Please sign in again.")
      /// Something went wrong. Please try again.
      internal static let unexpected = SwiftGen.tr("Localizable", "network.error.unexpected", fallback: "Something went wrong. Please try again.")
    }
  }
  internal enum Notifications {
    /// No notifications yet
    internal static let empty = SwiftGen.tr("Localizable", "notifications.empty", fallback: "No notifications yet")
    /// Tap to mark as read
    internal static let markRead = SwiftGen.tr("Localizable", "notifications.markRead", fallback: "Tap to mark as read")
    /// Notifications
    internal static let title = SwiftGen.tr("Localizable", "notifications.title", fallback: "Notifications")
    /// Unread: %lld
    internal static func unreadCount(_ p1: Int) -> String {
      return SwiftGen.tr("Localizable", "notifications.unreadCount", p1, fallback: "Unread: %lld")
    }
  }
  internal enum Product {
    /// Price
    internal static let price = SwiftGen.tr("Localizable", "product.price", fallback: "Price")
    /// Size
    internal static let size = SwiftGen.tr("Localizable", "product.size", fallback: "Size")
    /// Product
    internal static let title = SwiftGen.tr("Localizable", "product.title", fallback: "Product")
  }
  internal enum Profile {
    /// Change email
    internal static let changeEmail = SwiftGen.tr("Localizable", "profile.changeEmail", fallback: "Change email")
    /// Change password
    internal static let changePassword = SwiftGen.tr("Localizable", "profile.changePassword", fallback: "Change password")
    /// An email was sent to %@. Confirm your new address using the link, then refresh your profile. Your previous email remains active until confirmation.
    internal static func confirmNewEmail(_ p1: Any) -> String {
      return SwiftGen.tr("Localizable", "profile.confirmNewEmail", String(describing: p1), fallback: "An email was sent to %@. Confirm your new address using the link, then refresh your profile. Your previous email remains active until confirmation.")
    }
    /// Current password
    internal static let currentPassword = SwiftGen.tr("Localizable", "profile.currentPassword", fallback: "Current password")
    /// We will send an email to your new address. The address will change after you confirm it using the link.
    internal static let emailHint = SwiftGen.tr("Localizable", "profile.emailHint", fallback: "We will send an email to your new address. The address will change after you confirm it using the link.")
    /// New email
    internal static let newEmail = SwiftGen.tr("Localizable", "profile.newEmail", fallback: "New email")
    /// New password
    internal static let newPassword = SwiftGen.tr("Localizable", "profile.newPassword", fallback: "New password")
    /// Password changed.
    internal static let passwordChanged = SwiftGen.tr("Localizable", "profile.passwordChanged", fallback: "Password changed.")
    /// At least 6 characters
    internal static let passwordHint = SwiftGen.tr("Localizable", "profile.passwordHint", fallback: "At least 6 characters")
    /// Refresh profile
    internal static let refresh = SwiftGen.tr("Localizable", "profile.refresh", fallback: "Refresh profile")
    /// Repeat new password
    internal static let repeatNewPassword = SwiftGen.tr("Localizable", "profile.repeatNewPassword", fallback: "Repeat new password")
    /// Save password
    internal static let savePassword = SwiftGen.tr("Localizable", "profile.savePassword", fallback: "Save password")
    /// Send confirmation
    internal static let sendConfirmation = SwiftGen.tr("Localizable", "profile.sendConfirmation", fallback: "Send confirmation")
    /// Account settings
    internal static let settings = SwiftGen.tr("Localizable", "profile.settings", fallback: "Account settings")
    /// Sign out
    internal static let signOut = SwiftGen.tr("Localizable", "profile.signOut", fallback: "Sign out")
    /// Profile
    internal static let title = SwiftGen.tr("Localizable", "profile.title", fallback: "Profile")
    internal enum Error {
      /// Enter your current password
      internal static let currentPasswordRequired = SwiftGen.tr("Localizable", "profile.error.currentPasswordRequired", fallback: "Enter your current password")
      /// Your new password must contain at least 6 characters
      internal static let passwordTooShort = SwiftGen.tr("Localizable", "profile.error.passwordTooShort", fallback: "Your new password must contain at least 6 characters")
      /// Enter a different email
      internal static let sameEmail = SwiftGen.tr("Localizable", "profile.error.sameEmail", fallback: "Enter a different email")
      /// Your new password must differ from your current password
      internal static let samePassword = SwiftGen.tr("Localizable", "profile.error.samePassword", fallback: "Your new password must differ from your current password")
    }
  }
  internal enum Welcome {
    /// Old money style
    internal static let subtitle = SwiftGen.tr("Localizable", "welcome.subtitle", fallback: "Old money style")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension SwiftGen {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
