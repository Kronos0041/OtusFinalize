import SwiftUI

enum CategoryCollectionButtonType {
    case selected
    case notSelected

    init(isSelected: Bool) { self = isSelected ? .selected : .notSelected }

    var style: CategoryCollectionButtonStyleModel {
        switch self {
        case .selected:
            return CategoryCollectionButtonStyleModel(
                foregroundColor: .appBlack,
                indicatorColor: .appBlack
            )
        case .notSelected:
            return CategoryCollectionButtonStyleModel()
        }
    }
}
