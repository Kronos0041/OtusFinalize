import SwiftUI

/// Заглушка «пусто / нет сети / ошибка» с кнопкой повтора.
struct StatePlaceholder: View {
    let systemImage: String
    let title: String
    var message: Text? = nil
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.appGray)
            Text(title).font(.headline).multilineTextAlignment(.center)
            if let message {
                message.font(.footnote).foregroundColor(.appGray).multilineTextAlignment(.center)
            }
            if let retry { Button(SwiftGen.Common.retry, action: retry).padding(.top, 4) }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
