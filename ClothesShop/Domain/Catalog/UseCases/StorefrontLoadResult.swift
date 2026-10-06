struct StorefrontLoadResult {
    let catalog: Result<Catalog, Error>
    let cart: Result<[CartItem], Error>
    let settings: Result<StoreSettings, Error>
}
