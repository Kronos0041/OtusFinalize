//
//  CategoryCollectionButtonModel.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct CategoryCollectionButtonModel: Identifiable, Equatable {
    let id: String
    var title: String
}

struct CategoryCollectionButtonStyleModel {
    var foregroundColor: Color = Color.appBlack
    var backgroundColor: Color = Color.appGray.opacity(0.2)
}

/// Стиль «чипа» категории. Вычисляется из выбранного индекса, а не хранится в модели.
enum CategoryCollectionButtonEnum {
    case selected
    case notSelected

    init(isSelected: Bool) {
        self = isSelected ? .selected : .notSelected
    }

    var state: CategoryCollectionButtonStyleModel {
        switch self {
        case .selected:
            return CategoryCollectionButtonStyleModel(foregroundColor: Color.appWhite,
                                                      backgroundColor: Color.appBlack)
        case .notSelected:
            return CategoryCollectionButtonStyleModel()
        }
    }
}
