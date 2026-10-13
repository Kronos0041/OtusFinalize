import SwiftUI

struct ProductPurchaseBar: View {
    let width: CGFloat
    let isInCart: Bool
    let canModifyCart: Bool
    let isLiked: Bool
    let toggleCart: () -> Void
    let toggleLike: () -> Void

    /// Кнопка избранного чуть выше кнопки «Добавить», чтобы сердце было крупным и в него легко попасть.
    private let likeSize = ComponentConstants.Layout.buttonHeight + 6
    private let spacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: spacing) {
                Button(action: toggleCart) {
                    Label(isInCart ? SwiftGen.Cart.added : SwiftGen.Common.add,
                          systemImage: isInCart ? "bag.badge.minus" : "bag.badge.plus")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: max(0, width - horizontalPadding * 2 - spacing - likeSize), height: ComponentConstants.Layout.buttonHeight)
                        .foregroundColor(.appWhite)
                        .background(canModifyCart ? Color.appBlack : Color.appGray)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(!canModifyCart)
                .accessibilityHint(canModifyCart ? "" : SwiftGen.Cart.chooseSize)

                LikeButton(isLiked: isLiked, size: likeSize, action: toggleLike)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 12)
        }
        .background(Color.appWhite)
    }
}

struct ProductPurchaseBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductPurchaseBar(
                width: 390,
                isInCart: false,
                canModifyCart: true,
                isLiked: false,
                toggleCart: {},
                toggleLike: {}
            )
                .previewLayout(.sizeThatFits)
                .previewThemes("Не в корзине")
            ProductPurchaseBar(
                width: 390,
                isInCart: true,
                canModifyCart: true,
                isLiked: true,
                toggleCart: {},
                toggleLike: {}
            )
                .previewLayout(.sizeThatFits)
                .previewThemes("В корзине, в избранном")
            ProductPurchaseBar(
                width: 390,
                isInCart: false,
                canModifyCart: false,
                isLiked: false,
                toggleCart: {},
                toggleLike: {}
            )
                .previewLayout(.sizeThatFits)
                .previewThemes("Размер не выбран")
        }
    }
}
