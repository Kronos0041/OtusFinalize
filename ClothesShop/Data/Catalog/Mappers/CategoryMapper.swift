enum CategoryMapper {
    static func map(_ dto: CategoryDTO) -> Category {
        Category(id: dto.id, title: dto.title, order: dto.order)
    }
}
