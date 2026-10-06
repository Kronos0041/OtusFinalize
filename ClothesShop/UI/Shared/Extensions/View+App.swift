import SwiftUI

extension View {
    func previewThemes() -> some View {
        Group {
            self.foregroundColor(.appBlack).background(Color.appWhite)
                .preferredColorScheme(.light).previewDisplayName("Light")
            self.foregroundColor(.appBlack).background(Color.appWhite)
                .preferredColorScheme(.dark).previewDisplayName("Dark")
        }
    }

    func getWidth() -> CGFloat { AppLayout.screenWidth }
    func getHeight() -> CGFloat { AppLayout.screenHeight }
    func saveSize(in size: Binding<CGSize>) -> some View { modifier(SizeCalculator(size: size)) }
}
