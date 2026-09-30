//
//  SearchTextFiled.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Сейчас нигде не используется (поиск на главном экране закомментирован).
struct SearchTextFiled: View {
    let frame: (width: CGFloat, height: CGFloat)
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.appBlack)
            TextField(placeholder, text: $text)
        }
        .padding()
        .frame(width: frame.width, height: frame.height)
        .background(Color.appSliver)
        .cornerRadius(10)
    }
}

struct SearchTextFiled_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextFiled(frame: (340, 50), placeholder: "Поиск", text: .constant(""))
    }
}
