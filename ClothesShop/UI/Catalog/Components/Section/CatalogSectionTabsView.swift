//
//  CatalogSectionTabsView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Фильтр категорий + страницы с товарами. `CatalogViewModel` приходит из окружения.
struct CatalogSectionTabsView: View {
    var body: some View {
        VStack {
            CategoryCollectionView()
            CategoryCollectionTab()
        }
    }
}

struct CatalogSectionTabsView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogSectionTabsView()
            .environmentObject(AppDIContainer.shared.makeCatalogViewModel())
            .previewThemes()
    }
}
