//
//  CategoryCollectionCellView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct CategoryCollectionCellView: View {
    let item: CategoryUIModel
    let isSelected: Bool
    let width: CGFloat
    let onTap: () -> Void

    private var style: CategoryCollectionButtonStyleModel {
        CategoryCollectionButtonType(isSelected: isSelected).style
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: ComponentConstants.CategoryPicker.titleIndicatorSpacing) {
                Text(item.title)
                    .font(.system(size: ComponentConstants.CategoryPicker.fontSize, weight: isSelected ? .semibold : .regular))
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(style.indicatorColor)
                    .frame(height: ComponentConstants.CategoryPicker.indicatorHeight)
            }
            .foregroundColor(style.foregroundColor)
            .frame(width: width, height: ComponentConstants.CategoryPicker.itemHeight)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct CategoryCollectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionCellView(
            item: CatalogSectionUIModel.allCategory,
            isSelected: true,
            width: 80
        ) {}
            .previewThemes()
    }
}
