import SwiftUI

extension EnvironmentValues {
    var imageLoadMaxAttempts: Int {
        get { self[ImageLoadMaxAttemptsKey.self] }
        set { self[ImageLoadMaxAttemptsKey.self] = newValue }
    }
}
