struct CartItemUIModel: Identifiable, Equatable {
    let id: String
    let product: CatalogItemUIModel
    let size: String?
    let quantity: Int

    /// Та же позиция с актуальным товаром и/или количеством.
    func with(product: CatalogItemUIModel? = nil, quantity: Int? = nil) -> CartItemUIModel {
        CartItemUIModel(id: id, product: product ?? self.product, size: size, quantity: quantity ?? self.quantity)
    }
}
