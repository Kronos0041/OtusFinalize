import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var products: CatalogViewModel

    var body: some View {
        NavigationView {
            ViewModeView(products.favoritesMode,
                         emptyTitle: SwiftGen.Favorites.empty,
                         emptySystemImage: "heart",
                         retry: { products.reload() }) { favorites in
                CatalogGridView(section: CatalogSectionViewModel(
                        id: "favorites",
                        category: .init(id: "favorites", title: SwiftGen.Favorites.title),
                        products: favorites
                    ), emptyTitle: SwiftGen.Favorites.empty)
            }
            .navigationTitle(SwiftGen.Favorites.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppDIContainer.shared.makeCatalogViewModel()
        viewModel.applyPreview(products: CartPreviewData.items.map(\.product),
                               favoriteIDs: Set(CartPreviewData.items.map { $0.product.id }))
        return FavoritesView()
            .environmentObject(viewModel)
            .previewThemes()
    }
}
#endif
