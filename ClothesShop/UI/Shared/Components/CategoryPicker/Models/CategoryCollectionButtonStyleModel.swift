import SwiftUI

struct CategoryCollectionButtonStyleModel {
    let foregroundColor: Color
    let indicatorColor: Color

    init(foregroundColor: Color = .appGray, indicatorColor: Color = .clear) {
        self.foregroundColor = foregroundColor
        self.indicatorColor = indicatorColor
    }
}
