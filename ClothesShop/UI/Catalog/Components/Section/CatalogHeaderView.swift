import SwiftUI

/// Поиск и переключатель категорий, которые прокручиваются вместе с каталогом.
struct CatalogHeaderView: View {
    @Environment(CatalogViewModel.self) private var catalogViewModel

    var body: some View {
        VStack(spacing: 15) {
            SearchTextField(
                frame: (getWidth() - ComponentConstants.Layout.sideInset, 50),
                placeholder: SwiftGen.Common.search,
                text: Binding(
                    get: { catalogViewModel.searchText },
                    set: { catalogViewModel.updateSearchText($0) }
                )
            )

            CategoryCollectionView()
        }
        .padding(.top, 15)

        Divider()
    }
}

#if DEBUG
struct CatalogHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogHeaderView()
            .environment(AppDIContainer.mock().makeLoadedCatalogViewModel())
            .previewLayout(.sizeThatFits)
            .previewThemes()
    }
}
#endif
