import SwiftUI
import UIKit

/// Картинка по URL с повторной загрузкой.
///
/// Загрузка привязана к жизненному циклу view: при уходе с экрана задача отменяется,
/// а при возвращении запускается снова. Успешный ответ сохраняется в общем `URLCache`.
struct RemoteImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var placeholderIconSize: CGFloat = ComponentConstants.RemoteImage.placeholderIconSize

    @Environment(\.imageLoadMaxAttempts) private var maxAttempts
    @State private var image: UIImage?
    @State private var loadedURL: URL?
    @State private var didFail = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if url == nil || didFail {
                placeholder
            } else {
                loading
            }
        }
        .task(id: url) {
            await loadImage(maxAttempts: maxAttempts)
        }
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

    @MainActor
    private func loadImage(maxAttempts: Int) async {
        guard let url else { return }

        if loadedURL != url {
            image = nil
            loadedURL = nil
            didFail = false
        }

        guard image == nil else { return }

        didFail = false
        let attemptsCount = max(0, maxAttempts) + 1

        for attempt in 0..<attemptsCount {
            do {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                let (data, response) = try await URLSession.shared.data(for: request)
                try Task.checkCancellation()

                guard let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode),
                      let loadedImage = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }

                image = loadedImage
                loadedURL = url
                return
            } catch is CancellationError {
                return
            } catch {
                guard attempt < attemptsCount - 1 else {
                    didFail = true
                    return
                }

                try? await Task.sleep(for: .milliseconds(ComponentConstants.RemoteImage.retryDelayMilliseconds))
            }
        }
    }
}

struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RemoteImageView(url: nil)
                .frame(width: 160, height: 160)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Без URL — заглушка")
            RemoteImageView(
                url: URL(string: "https://test-6d334.web.app/products/glasses-navigator.png"),
                contentMode: .fit
            )
                .frame(width: 160, height: 160)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Загрузка по URL")
        }
    }
}
