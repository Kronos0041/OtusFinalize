//
//  CategoryCollectionCellTab.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Листаемые страницы каталога — по одной на категорию.
struct CategoryCollectionTab: View {
    @EnvironmentObject var products: MainGrideVM

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            TabView(selection: $products.selected) {
                ForEach(products.list.indices, id: \.self) { index in
                    MainGridView(section: products.list[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        }
    }
}

struct CategoryCollectionTab_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCollectionTab()
            .environmentObject(MainGrideVM())
    }
}
