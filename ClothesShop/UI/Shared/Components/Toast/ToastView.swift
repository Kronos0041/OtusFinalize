import SwiftUI

/// Короткое уведомление: чёрная плашка с иконкой и текстом. И иконку, и текст передаёт вызывающий.
struct ToastView: View {
    let text: String
    /// Имя SF Symbol.
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.black, Color.white)
                .accessibilityHidden(true)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
    }
}

extension ToastMessage.Kind {
    /// Иконка уведомления по его смыслу.
    var systemImage: String {
        switch self {
        case .error: return "exclamationmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

extension View {
    /// Показывает `ToastView` сверху экрана, пока `toast` не `nil`; само скрывается через 3 секунды.
    func toast(_ toast: ToastMessage?, dismiss: @escaping () -> Void) -> some View {
        overlay(alignment: .top) {
            if let toast {
                ToastView(text: toast.text, systemImage: toast.kind.systemImage)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture(perform: dismiss)
                    .task(id: toast) {
                        try? await Task.sleep(for: .seconds(3))
                        guard !Task.isCancelled else { return }
                        dismiss()
                    }
                    .onAppear { UIAccessibility.post(notification: .announcement, argument: toast.text) }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toast)
    }
}

#if DEBUG
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToastView(text: "Неверный email или пароль.", systemImage: ToastMessage.Kind.error.systemImage)
            ToastView(text: "Письмо отправлено повторно.", systemImage: ToastMessage.Kind.success.systemImage)
            ToastView(text: "Вход через Google пока в разработке", systemImage: ToastMessage.Kind.info.systemImage)
        }
        .previewLayout(.sizeThatFits)
        .previewThemes()
    }
}
#endif
