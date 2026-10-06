struct CartItemViewModel: Identifiable, Equatable {
    let id: String
    var product: CatalogItemViewModel
    let size: String?
    var quantity: Int
}
