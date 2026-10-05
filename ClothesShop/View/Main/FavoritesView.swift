import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var products: MainGrideVM

    var body: some View {
        NavigationView {
            ViewModeView(products.favoritesViewMode,
                         emptyTitle: SwiftGen.Favorites.empty,
                         emptySystemImage: "heart",
                         retry: { products.reload() }) { favorites in
                MainGridView(section: ShopItemModel(
                        id: "favorites",
                        categoryName: .init(id: "favorites", title: SwiftGen.Favorites.title),
                        product: favorites
                    ), emptyTitle: SwiftGen.Favorites.empty)
            }
            .navigationTitle(SwiftGen.Favorites.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { products.loadIfNeeded() }
    }
}

#if DEBUG
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(MainGrideVM(
                previewProducts: CartPreviewData.items.map(\.product),
                likedProductIDs: Set(CartPreviewData.items.map { $0.product.id })))
            .previewThemes()
    }
}
#endif
