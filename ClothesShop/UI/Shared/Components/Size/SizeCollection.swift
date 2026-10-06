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
            HStack(spacing: 12) {
                ForEach(sizes, id: \.self) { size in
                    Button { selection = size } label: {
                        Text(verbatim: size)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selection == size ? .appWhite : .appBlack)
                        .padding(.horizontal, 16)
                        .frame(minWidth: 52, minHeight: 50)
                        .background(selection == size ? Color.appBlack : Color.appWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appGray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == size ? .isSelected : [])
                }
            }
            .padding(1)
        }

    }
}

struct SizeCollection_Previews: PreviewProvider {
    static var previews: some View {
        SizeCollection(sizes: ["S", "M", "L"], selection: .constant("M"))
            .previewThemes()
    }
}
