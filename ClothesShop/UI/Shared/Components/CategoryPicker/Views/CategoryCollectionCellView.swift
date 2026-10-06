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
    let onTap: () -> Void

    private var style: CategoryCollectionButtonStyleModel {
        CategoryCollectionButtonType(isSelected: isSelected).style
    }

    var body: some View {
        Button(action: onTap) {
            Text(item.title)
                .padding()
                .frame(height: 40)
                .foregroundColor(style.foregroundColor)
                .background(style.backgroundColor)
                .cornerRadius(10)
                .padding(.leading, 20)
        }
    }
}

struct CategoryCollectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionCellView(item: CatalogSectionViewModel.allCategory, isSelected: true) {}
            .previewThemes()
    }
}
