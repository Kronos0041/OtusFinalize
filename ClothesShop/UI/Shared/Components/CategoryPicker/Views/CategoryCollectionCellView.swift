//
//  CategoryCollectionCellView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct CategoryCollectionCellView: View {
    let item: CategoryItemViewModel
    let isSelected: Bool
    let width: CGFloat
    let onTap: () -> Void

    private var style: CategoryCollectionButtonStyleModel {
        CategoryCollectionButtonType(isSelected: isSelected).style
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(item.title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(style.indicatorColor)
                    .frame(height: 2)
            }
            .foregroundColor(style.foregroundColor)
            .frame(width: width, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct CategoryCollectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionCellView(
            item: CatalogSectionViewModel.allCategory,
            isSelected: true,
            width: 80
        ) {}
            .previewThemes()
    }
}
