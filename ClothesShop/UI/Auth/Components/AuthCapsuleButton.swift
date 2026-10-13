import SwiftUI

/// Небольшая белая кнопка-капсула для второстепенных действий («Не могу вспомнить»).
struct AuthCapsuleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appBlack)
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background(Color.appWhite, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
