//
//  MainTabView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Фильтр категорий + страницы с товарами. `MainGrideVM` приходит из окружения.
struct MainTabView: View {
    var body: some View {
        VStack {
            CategoryCollectionView()
            CategoryCollectionTab()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(MainGrideVM())
            .previewThemes()
    }
}
