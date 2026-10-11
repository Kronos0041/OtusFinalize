struct CartItemUIModel: Identifiable, Equatable {
    let id: String
    var product: CatalogItemUIModel
    let size: String?
    var quantity: Int
}
