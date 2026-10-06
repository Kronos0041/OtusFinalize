import SwiftUI

struct ProductPurchaseBar: View {
    let width: CGFloat
    let isInCart: Bool
    let canModifyCart: Bool
    let isLiked: Bool
    let toggleCart: () -> Void
    let toggleLike: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Button(action: toggleCart) {
                    Label(isInCart ? SwiftGen.Cart.added : SwiftGen.Common.add,
                          systemImage: isInCart ? "bag.badge.minus" : "bag.badge.plus")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: max(0, width - 104), height: AppLayout.buttonHeight)
                        .foregroundColor(.appWhite)
                        .background(canModifyCart ? Color.appBlack : Color.appGray)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(!canModifyCart)

                Button(action: toggleLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(isLiked ? .appRed : .appBlack)
                        .frame(width: 52, height: AppLayout.buttonHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appGray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isLiked ? SwiftGen.Favorites.remove : SwiftGen.Favorites.add)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.appWhite)
    }
}

struct ProductPurchaseBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductPurchaseBar(width: 390, isInCart: false, canModifyCart: true,
                               isLiked: false, toggleCart: {}, toggleLike: {})
                .previewLayout(.sizeThatFits)
                .previewThemes("Не в корзине")
            ProductPurchaseBar(width: 390, isInCart: true, canModifyCart: true,
                               isLiked: true, toggleCart: {}, toggleLike: {})
                .previewLayout(.sizeThatFits)
                .previewThemes("В корзине, в избранном")
            ProductPurchaseBar(width: 390, isInCart: false, canModifyCart: false,
                               isLiked: false, toggleCart: {}, toggleLike: {})
                .previewLayout(.sizeThatFits)
                .previewThemes("Размер не выбран")
        }
    }
}
