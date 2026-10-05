import SwiftUI

struct CartItemsListView: View {
    let items: [CartItem]
    let total: Int
    let changeQuantity: (UUID, Int) -> Void
    let remove: (UUID) -> Void

    var body: some View {
        List {
            ForEach(items) { item in
                CartSwipeDeleteRow(remove: { remove(item.id) }) {
                    CartRowView(item: item,
                                decrease: {
                                    if item.quantity == 1 {
                                        withAnimation { changeQuantity(item.id, -1) }
                                    } else {
                                        changeQuantity(item.id, -1)
                                    }
                                },
                                increase: { changeQuantity(item.id, 1) })
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.appWhite)
            }
            HStack {
                Text(SwiftGen.Cart.total).foregroundColor(.appGray)
                Spacer()
                Text(verbatim: PriceFormatter.string(from: total))
                    .font(.system(size: 23, weight: .semibold))
            }
                .padding(.vertical, 16)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.appWhite)
        }
        .listStyle(.plain)
    }
}

private struct CartSwipeDeleteRow<Content: View>: View {
    private let actionWidth: CGFloat = 96
    private let animation = Animation.interactiveSpring(response: 0.32,
                                                         dampingFraction: 0.82,
                                                         blendDuration: 0.15)
    let remove: () -> Void
    @ViewBuilder let content: Content

    @State private var restingOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    private var offset: CGFloat {
        let proposedOffset = min(0, restingOffset + dragOffset)
        guard proposedOffset < -actionWidth else { return proposedOffset }
        return -actionWidth + (proposedOffset + actionWidth) * 0.2
    }

    private var revealProgress: CGFloat {
        min(1, max(0, -offset / actionWidth))
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive) {
                withAnimation(animation) { remove() }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 22, weight: .medium))
                    Text(SwiftGen.Cart.delete)
                        .font(.caption)
                }
                .foregroundColor(.appWhite)
                .frame(width: actionWidth)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .scaleEffect(0.82 + revealProgress * 0.2)
                .opacity(revealProgress)
            }
            .buttonStyle(.plain)
            .background(Color.appRed)

            content
                .background(Color.appWhite)
                .overlay {
                    if restingOffset != 0 && dragOffset == 0 {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { close() }
                    }
                }
                .offset(x: offset)
        }
        .clipped()
        .contentShape(Rectangle())
        .simultaneousGesture(swipeGesture)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($dragOffset) { value, state, _ in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let projectedOffset = restingOffset + value.predictedEndTranslation.width
                withAnimation(animation) {
                    restingOffset = projectedOffset < -actionWidth / 2 ? -actionWidth : 0
                }
            }
    }

    private func close() {
        withAnimation(animation) {
            restingOffset = 0
        }
    }
}

#if DEBUG
struct CartItemsListView_Previews: PreviewProvider {
    static var previews: some View {
        CartItemsListView(items: CartPreviewData.items, total: CartPreviewData.total,
                          changeQuantity: { _, _ in }, remove: { _ in })
            .background(Color.appWhite)
            .previewThemes()
    }
}
#endif
