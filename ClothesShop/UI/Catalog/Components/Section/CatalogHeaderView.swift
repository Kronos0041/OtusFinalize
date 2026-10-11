import SwiftUI

/// Поиск и переключатель категорий, которые прокручиваются вместе с каталогом.
struct CatalogHeaderView: View {
    @Environment(CatalogViewModel.self) private var products

    var body: some View {
        @Bindable var products = products

        VStack(spacing: 15) {
            SearchTextField(
                frame: (getWidth() - AppLayout.sideInset, 50),
                placeholder: SwiftGen.Common.search,
                text: $products.searchText
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
            .environment(AppDIContainer.preview().makeLoadedCatalogViewModel())
            .previewLayout(.sizeThatFits)
            .previewThemes()
    }
}
#endif
