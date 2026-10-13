import SwiftUI

extension View {
    /// Показывает превью в светлой и тёмной теме.
    /// - Parameter name: название варианта; в группе превью нужно, чтобы отличать варианты в Canvas.
    func previewThemes(_ name: String? = nil) -> some View {
        let prefix = name.map { "\($0) · " } ?? ""
        return Group {
            self.foregroundColor(.appBlack).background(Color.appWhite)
                .preferredColorScheme(.light).previewDisplayName(prefix + "Light")
            self.foregroundColor(.appBlack).background(Color.appWhite)
                .preferredColorScheme(.dark).previewDisplayName(prefix + "Dark")
        }
    }

    func getWidth() -> CGFloat { UIScreen.main.bounds.width }
}
