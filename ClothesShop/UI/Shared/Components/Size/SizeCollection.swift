//
//  SizeCollection.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct SizeCollection: View {
    let sizes: [String]
    @Binding var selection: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ComponentConstants.SizeCollection.spacing) {
                ForEach(sizes, id: \.self) { size in
                    Button { selection = size } label: {
                        Text(verbatim: size)
                        .font(.system(size: ComponentConstants.SizeCollection.fontSize, weight: .medium))
                        .foregroundColor(selection == size ? .appWhite : .appBlack)
                        .padding(.horizontal, ComponentConstants.SizeCollection.horizontalPadding)
                        .frame(minWidth: ComponentConstants.SizeCollection.minCellWidth, minHeight: ComponentConstants.SizeCollection.minCellHeight)
                        .background(selection == size ? Color.appBlack : Color.appWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: ComponentConstants.SizeCollection.cornerRadius)
                                .stroke(Color.appGray.opacity(ComponentConstants.SizeCollection.borderOpacity), lineWidth: ComponentConstants.SizeCollection.borderWidth)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == size ? .isSelected : [])
                }
            }
            .padding(ComponentConstants.SizeCollection.borderInset)
        }

    }
}

struct SizeCollection_Previews: PreviewProvider {
    static var previews: some View {
        SizeCollection(sizes: ["S", "M", "L"], selection: .constant("M"))
            .previewThemes()
    }
}
