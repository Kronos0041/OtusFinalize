/// Экраны, которые открываются поверх вкладок «Главная» и «Избранное».
enum CatalogRoute: Hashable {
    case notifications
    /// Карточка товара. Передаётся id: экран всегда берёт актуальный товар из каталога.
    case productDetails(productID: String)
}
