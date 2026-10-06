import SwiftUI

extension Image {
    init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String),
              let image = UIImage(data: data) else { return nil }
        self = Image(uiImage: image)
    }
}
