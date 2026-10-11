import SwiftUI

struct CartActionsView: View {
    let isEmpty: Bool
    let checkout: () -> Void
    let continueShopping: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if !isEmpty {
                Button(action: checkout) {
                    Text(SwiftGen.Cart.checkout)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.appWhite)
                        .background(Color.appBlack)
                        .cornerRadius(10)
                }
            }
            Button(SwiftGen.Cart.continueShopping, action: continueShopping)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

#if DEBUG
struct CartActionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CartActionsView(isEmpty: false, checkout: {}, continueShopping: {})
                .previewLayout(.sizeThatFits)
                .previewThemes("Корзина с товарами")
            CartActionsView(isEmpty: true, checkout: {}, continueShopping: {})
                .previewLayout(.sizeThatFits)
                .previewThemes("Пустая корзина")
        }
    }
}
#endif
