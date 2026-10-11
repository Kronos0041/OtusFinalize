import SwiftUI

/// Заглушка «пусто / нет сети / ошибка» с кнопкой повтора.
struct StatePlaceholder: View {
    let systemImage: String
    let title: String
    var message: Text? = nil
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: ComponentConstants.StatePlaceholder.spacing) {
            Image(systemName: systemImage)
                .font(.system(size: ComponentConstants.StatePlaceholder.iconSize))
                .foregroundColor(.appGray)
            Text(title).font(.headline).multilineTextAlignment(.center)
            if let message {
                message.font(.footnote).foregroundColor(.appGray).multilineTextAlignment(.center)
            }
            if let retry { Button(SwiftGen.Common.retry, action: retry).padding(.top, ComponentConstants.StatePlaceholder.retryTopPadding) }
        }
        .padding(ComponentConstants.StatePlaceholder.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
