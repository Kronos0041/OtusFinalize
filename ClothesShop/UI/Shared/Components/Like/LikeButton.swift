import SwiftUI

/// Кнопка «в избранное». Сердце меняется анимацией замены символа.
/// В iOS 26 кнопка стеклянная и краснеет, когда товар в избранном.
struct LikeButton: View {
    let isLiked: Bool
    /// Диаметр кнопки.
    var size: CGFloat = 40
    let action: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            // `.glassEffect` вместо стиля `.glassProminent`: системный стиль сам выбирает размер
            // и плотность стекла. Здесь размер ровно `size`, а пустое состояние — матовое стекло
            // без заливки: фото товара немного просвечивает, а иконка остаётся читаемой.
            // Прозрачное `.clear` не подходит: оно работает как линза и искажает фото под собой.
            Button(action: action) {
                icon
                    .foregroundStyle(isLiked ? Color.white : Color.appBlack)
                    .frame(width: size, height: size)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(
                isLiked ? .regular.tint(.appRed).interactive() : .regular.interactive(),
                in: .circle
            )
            .accessibilityLabel(isLiked ? SwiftGen.Favorites.remove : SwiftGen.Favorites.add)
        } else {
            Button(action: action) {
                icon
                    .foregroundStyle(isLiked ? Color.appRed : Color.appBlack)
                    .frame(width: size, height: size)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isLiked ? SwiftGen.Favorites.remove : SwiftGen.Favorites.add)
        }
    }

    private var icon: some View {
        Image(systemName: isLiked ? "heart.fill" : "heart")
            .font(.system(size: size * 0.45, weight: .medium))
            .contentTransition(.symbolEffect(.replace))
    }
}

#if DEBUG
struct LikeButton_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var isLiked = false

        var body: some View {
            LikeButton(isLiked: isLiked) {
                withAnimation { isLiked.toggle() }
            }
            .padding()
        }
    }

    static var previews: some View {
        Demo()
            .previewLayout(.sizeThatFits)
            .previewThemes()
    }
}
#endif
