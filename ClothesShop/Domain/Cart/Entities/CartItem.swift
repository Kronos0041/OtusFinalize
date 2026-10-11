struct CartItem: Identifiable, Equatable {
    let id: String
    let productID: Product.ID
    let size: String?
    let quantity: Int
}
