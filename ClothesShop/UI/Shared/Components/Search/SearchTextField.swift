//
//  SearchTextField.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

/// Поле поиска каталога с очисткой введённого запроса.
struct SearchTextField: View {
    let frame: (width: CGFloat, height: CGFloat)
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: ComponentConstants.Search.iconSize, height: ComponentConstants.Search.iconSize)
                .foregroundColor(Color.appBlack)
                .accessibilityHidden(true)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)
                .onSubmit { isFocused = false }
            Button {
                text = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.appGray)
                    .frame(width: ComponentConstants.Search.clearButtonSize, height: ComponentConstants.Search.clearButtonSize)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(SwiftGen.Catalog.Search.clear))
            .opacity(text.isEmpty ? 0 : 1)
            .disabled(text.isEmpty)
            .accessibilityHidden(text.isEmpty)
        }
        .padding()
        .frame(width: frame.width, height: frame.height)
        .background(Color.appSliver)
        .cornerRadius(ComponentConstants.Search.cornerRadius)
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(frame: (340, 50), placeholder: SwiftGen.Common.search, text: .constant(""))
            .previewThemes()
    }
}
