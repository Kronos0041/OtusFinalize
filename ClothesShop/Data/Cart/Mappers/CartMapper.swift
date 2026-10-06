enum CartMapper {
    static func map(_ dto: CartRecordDTO) -> CartItem {
        CartItem(id: dto.id, productID: dto.productID, size: dto.size, quantity: dto.quantity)
    }

    static func map(_ item: CartItem) -> CartRecordDTO {
        CartRecordDTO(id: item.id, productID: item.productID,
                      size: item.size, quantity: item.quantity)
    }
}
