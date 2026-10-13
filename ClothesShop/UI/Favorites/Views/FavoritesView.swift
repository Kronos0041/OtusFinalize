import SwiftUI

struct FavoritesView: View {
    @Environment(CatalogViewModel.self) private var catalogViewModel
    @State private var router = Router<CatalogRoute>()

    var body: some View {
        NavigationStack(path: Binding(get: { router.path }, set: router.updatePath)) {
            ViewModeView(
                catalogViewModel.favoritesMode,
                emptyTitle: SwiftGen.Favorites.empty,
                emptySystemImage: "heart",
                retry: { catalogViewModel.reload() }
            ) { favorites in
                let section = CatalogSectionUIModel(
                    id: "favorites",
                    category: .init(id: "favorites", title: SwiftGen.Favorites.title),
                    products: favorites
                )
                CatalogGridView(section: section, emptyTitle: SwiftGen.Favorites.empty)
            }
            .navigationTitle(SwiftGen.Favorites.title)
            .navigationBarTitleDisplayMode(.inline)
            .catalogDestinations()
        }
        .environment(router)
    }
}

#if DEBUG
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            content(AppDIContainer.mock(favoriteIDs: Set(PreviewData.cartRecords.map(\.productID))))
                .previewThemes("Есть избранное")
            content(AppDIContainer.mock())
                .previewThemes("Пусто")
        }
    }

    private static func content(_ container: AppDIContainer) -> some View {
        FavoritesView()
            .environment(container.makeLoadedCatalogViewModel())
            .environment(container.makeLoadedCartViewModel())
    }
}
#endif
