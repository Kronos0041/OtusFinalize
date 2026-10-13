import SwiftUI

/// Верхняя часть каталога: панель и поиск. Прокручивается вместе с товарами.
struct CatalogHeaderView: View {
    @Environment(CatalogViewModel.self) private var catalogViewModel
    let topBar: MainTopBar

    var body: some View {
        VStack(spacing: 16) {
            topBar

            SearchTextField(
                frame: (getWidth() - ComponentConstants.Layout.sideInset, 50),
                placeholder: SwiftGen.Common.search,
                text: Binding(
                    get: { catalogViewModel.searchText },
                    set: { catalogViewModel.updateSearchText($0) }
                )
            )
        }
        .padding(.bottom, 15)
    }
}

#if DEBUG
struct CatalogHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogHeaderView(topBar: MainTopBar(notificationCount: 3, clickBell: {}))
            .environment(AppDIContainer.mock().makeLoadedCatalogViewModel())
            .previewLayout(.sizeThatFits)
            .previewThemes()
    }
}
#endif
