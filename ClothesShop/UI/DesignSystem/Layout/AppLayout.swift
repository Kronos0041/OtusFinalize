import SwiftUI

enum AppLayout {
    static let sideInset: CGFloat = 40
    static let buttonHeight: CGFloat = 50
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var fullWidthButton: (width: CGFloat, height: CGFloat) {
        (screenWidth - sideInset, buttonHeight)
    }
}
