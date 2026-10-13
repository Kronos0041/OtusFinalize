//
//  CatalogContentView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Каталог с закреплённой лентой категорий (sticky header).
///
/// Всё лежит в одном `ScrollView`: панель и поиск прокручиваются вместе с товарами,
/// а лента категорий — заголовок секции `LazyVStack(pinnedViews:)`, поэтому прилипает к верху сама.
/// Категории работают как фильтр: переключаются нажатием на ленту.
///
/// При смене категории `ScrollView` создаётся заново (`.id`), поэтому она всегда открывается с начала.
/// Ручной `scrollTo` здесь не годится: если новая категория короче, `LazyVStack` с закреплённой
/// секцией остаётся на старой позиции за концом списка и показывает белый экран.
struct CatalogContentView: View {
    @Environment(CatalogViewModel.self) private var catalogViewModel
    let topBar: MainTopBar

    /// Высота зоны под таб-баром: на неё остаётся отступ после последнего товара.
    @State private var bottomSafeArea: CGFloat = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                CatalogHeaderView(topBar: topBar)

                Section {
                    selectedProducts
                } header: {
                    VStack(spacing: 0) {
                        CategoryCollectionView()
                        Divider()
                    }
                    .background(Color(uiColor: .systemBackground))
                }
            }
        }
        .id(catalogViewModel.selectedCategoryIndex)
        .contentMargins(.bottom, bottomSafeArea, for: .scrollContent)
        .refreshable { await catalogViewModel.refresh() }
        // Сверху прокрутка обрезается по рамке: над закреплённой лентой товары не заходят под статус-бар.
        // Снизу рамка продлена под таб-бар, чтобы товары были видны под плавающей панелью;
        // отступ под панель после последнего товара задают `contentMargins`.
        .clipped()
        .ignoresSafeArea(.container, edges: .bottom)
        .onGeometryChange(for: CGFloat.self, of: \.safeAreaInsets.bottom) { bottomSafeArea = $0 }
    }

    @ViewBuilder
    private var selectedProducts: some View {
        let sections = catalogViewModel.filteredSections
        let index = catalogViewModel.selectedCategoryIndex
        if sections.indices.contains(index), !sections[index].products.isEmpty {
            CatalogProductsGrid(items: sections[index].products)
                .padding(.top, 10)
        } else if catalogViewModel.isSearching {
            StatePlaceholder(
                systemImage: "magnifyingglass",
                title: SwiftGen.Catalog.Search.empty,
                message: Text(SwiftGen.Catalog.Search.changeQuery)
            )
        }
    }
}

#if DEBUG
struct CatalogContentView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogContentView(topBar: MainTopBar(notificationCount: 3, clickBell: {}))
            .environment(AppDIContainer.mock().makeLoadedCatalogViewModel())
            .environment(Router<CatalogRoute>())
            .previewThemes()
    }
}
#endif
