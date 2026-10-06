import SwiftUI

struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.onAppear { size = proxy.size }
            }
        )
    }
}
