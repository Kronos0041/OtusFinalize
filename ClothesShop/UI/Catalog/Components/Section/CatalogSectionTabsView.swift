//
//  CatalogSectionTabsView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Листаемые страницы каталога. Поиск и категории находятся внутри `CatalogHeaderView`.
struct CatalogSectionTabsView: View {
    var body: some View {
        CategoryCollectionTab()
    }
}

#if DEBUG
struct CatalogSectionTabsView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogSectionTabsView()
            .environment(AppDIContainer.mock().makeLoadedCatalogViewModel())
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }
}
#endif
