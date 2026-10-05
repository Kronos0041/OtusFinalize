import SwiftUI

struct ProductPurchaseBar: View {
    let width: CGFloat
    let canAddToCart: Bool
    let isLiked: Bool
    let addToCart: () -> Void
    let toggleLike: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Button(action: addToCart) {
                    Label(SwiftGen.Common.add, systemImage: "bag.badge.plus")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: max(0, width - 104), height: AppLayout.buttonHeight)
                        .foregroundColor(.appWhite)
                        .background(canAddToCart ? Color.appBlack : Color.appGray)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(!canAddToCart)

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
            ProductPurchaseBar(width: 390, canAddToCart: true, isLiked: false,
                               addToCart: {}, toggleLike: {})
            ProductPurchaseBar(width: 390, canAddToCart: false, isLiked: true,
                               addToCart: {}, toggleLike: {})
        }
        .previewLayout(.sizeThatFits)
        .previewThemes()
    }
}
