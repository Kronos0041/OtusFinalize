import SwiftUI

/// Картинка по URL с повторной загрузкой.
///
/// `AsyncImage` сам не повторяет запрос: если загрузка отменилась (ячейка пересоздалась
/// или вкладка `TabView` перерисовалась в фоне), он навсегда остаётся в `.failure`.
/// Здесь при появлении заглушки на экране загрузка запускается заново —
/// не больше `maxAttempts` раз, повтор обычно отдаётся из `URLCache`.
struct RemoteImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var placeholderIconSize: CGFloat = 36

    @State private var attempt = 0
    private let maxAttempts = 3

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: contentMode)
            case .empty:
                if url == nil { placeholder } else { loading }
            case .failure:
                placeholder.onAppear(perform: retryIfPossible)
            @unknown default:
                placeholder
            }
        }
        // Новый идентификатор пересоздаёт AsyncImage и запускает загрузку заново.
        .id(attempt)
    }

    private var loading: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.system(size: placeholderIconSize))
            .foregroundColor(.appGray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func retryIfPossible() {
        guard url != nil, attempt < maxAttempts else { return }
        // Откладываем, чтобы не менять состояние во время построения body.
        DispatchQueue.main.async { attempt += 1 }
    }
}

struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RemoteImageView(url: nil)
            RemoteImageView(url: URL(string: "https://test-6d334.web.app/products/glasses-navigator.png"),
                            contentMode: .fit)
        }
        .frame(width: 160, height: 160)
        .previewLayout(.sizeThatFits)
    }
}
