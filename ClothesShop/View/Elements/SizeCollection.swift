//
//  SizeCollection.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct SizeCollection: View {
    let sizes: [String]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(sizes, id: \.self) { size in
                Text(size)
                    .bold()
                    .padding()
                    .foregroundColor(Color.appBlack)
                    .frame(width: 50, height: 50)
                    .background(Color.appWhite)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.appBlack, lineWidth: 1)
                    )
            }
            Spacer()
        }
        .frame(width: getWidth() - AppLayout.sideInset)
    }
}

struct SizeCollection_Previews: PreviewProvider {
    static var previews: some View {
        SizeCollection(sizes: ["S", "M", "L"])
    }
}
