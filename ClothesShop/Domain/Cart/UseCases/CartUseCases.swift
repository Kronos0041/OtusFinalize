/// Все операции над корзиной в одном месте: ViewModel зависит от одного объекта вместо четырёх.
/// Отдельные use case сохраняются (например, `GetCartUseCase` нужен ещё `GetShopDataUseCase`).
struct CartUseCases {
    let get: GetCartUseCase
    let add: AddCartItemUseCase
    let remove: RemoveCartItemUseCase
    let clear: ClearCartUseCase

    init(repository: CartRepositoryProtocol) {
        get = GetCartUseCase(repository: repository)
        add = AddCartItemUseCase(repository: repository)
        remove = RemoveCartItemUseCase(repository: repository)
        clear = ClearCartUseCase(repository: repository)
    }
}
