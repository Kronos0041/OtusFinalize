import SwiftUI

/// Картинка на весь экран на чёрном фоне.
///
/// Масштабирование — `ZoomableImageView` на `UIScrollView`: щипок, двойной тап, инерция, отскок.
/// Закрыть можно крестиком, свайпом вниз без увеличения или жестом VoiceOver «назад».
/// Кнопка «Поделиться» появляется, когда картинка загружена, и отправляет саму картинку.
struct FullScreenImageView: View {
    let url: URL?
    /// Название для подписи картинки и превью «Поделиться».
    var title: String = ""

    @Environment(\.dismiss) private var dismiss
    /// Сдвиг картинки вниз при закрытии свайпом; по нему затухает фон и прячутся кнопки.
    @State private var dismissOffset: CGFloat = 0
    @State private var loadedImage: UIImage?

    private typealias Constants = ComponentConstants.FullScreenImage

    var body: some View {
        Group {
            if let loadedImage {
                ZoomableImageView(
                    image: loadedImage,
                    accessibilityLabel: title,
                    onDismissDrag: { dismissOffset = $0 },
                    onDismiss: { dismiss() }
                )
            } else {
                // Пока картинки нет, показываются загрузка или заглушка; обычно она уже в кэше.
                RemoteImageView(url: url, contentMode: .fit) { loadedImage = $0 }
            }
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(backgroundOpacity).ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                if let loadedImage {
                    let image = Image(uiImage: loadedImage)
                    ShareLink(item: image, preview: SharePreview(title, image: image)) {
                        circleIcon("square.and.arrow.up")
                    }
                    .accessibilityLabel(Text(SwiftGen.Common.share))
                }
                Button { dismiss() } label: { circleIcon("xmark") }
                    .accessibilityLabel(Text(SwiftGen.Common.close))
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
            .opacity(dismissOffset == 0 ? 1 : 0)
            .animation(.easeOut(duration: 0.2), value: dismissOffset == 0)
        }
        // Стандартный жест VoiceOver «назад» (двумя пальцами буквой Z) закрывает экран.
        .accessibilityAction(.escape) { dismiss() }
        .presentationBackground(.clear)
        .statusBarHidden()
    }

    private var backgroundOpacity: Double {
        1 - min(Double(dismissOffset / Constants.dismissDistance), 1) * 0.6
    }

    private func circleIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: Constants.buttonIconSize, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .background(Circle().fill(.black.opacity(Constants.buttonBackgroundOpacity)))
    }
}

#if DEBUG
struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageView(url: PreviewData.watch.imageURL, title: PreviewData.watch.title)
    }
}
#endif
