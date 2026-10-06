enum CatalogMapper {
    static func map(_ dto: CatalogDTO) -> Catalog {
        Catalog(categories: dto.categories.map(CategoryMapper.map),
                products: dto.products.map(ProductMapper.map))
    }
}
