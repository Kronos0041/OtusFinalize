enum ProductMapper {
    static func map(_ dto: ProductDTO) -> Product {
        Product(id: dto.id,
                categoryID: dto.categoryId,
                imageURL: dto.imageURL,
                title: dto.title,
                shortDescription: dto.shortDescription,
                description: dto.description,
                price: dto.price,
                sizes: dto.sizes ?? [],
                badge: dto.badge,
                order: dto.order)
    }
}
