/// Данные магазина после стартовой загрузки. Каждая часть загружается независимо, поэтому хранится как `Result`.
struct ShopData {
    let catalog: Result<Catalog, Error>
    let cart: Result<[CartItem], Error>
    let settings: Result<StoreSettings, Error>
}
