//
//  ViewModeView.swift
//  ClothesShop
//
//  Created by Alex on 29.09.2026.
//

import SwiftUI

/// Показывает контент или заглушку в зависимости от `ViewMode`.
/// Общая оболочка области данных: навигация и постоянные действия остаются снаружи.
///
///     ViewModeView(viewModel.mode, emptyTitle: "Каталог пока пуст", retry: { viewModel.reload() }) { sections in
///         CatalogView(sections: sections)
///     }
struct ViewModeView<Value, Content: View>: View {
    private let mode: ViewMode<Value>
    private let emptyTitle: String
    private let emptySystemImage: String
    private let emptyMessage: String?
    private let retry: (() -> Void)?
    private let content: (Value) -> Content

    init(_ mode: ViewMode<Value>,
         emptyTitle: String = SwiftGen.Common.empty,
         emptySystemImage: String = "tray",
         emptyMessage: String? = nil,
         retry: (() -> Void)? = nil,
         @ViewBuilder content: @escaping (Value) -> Content) {
        self.mode = mode
        self.emptyTitle = emptyTitle
        self.emptySystemImage = emptySystemImage
        self.emptyMessage = emptyMessage
        self.retry = retry
        self.content = content
    }

    var body: some View {
        switch mode {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .content(let value):
            content(value)
        case .empty:
            StatePlaceholder(systemImage: emptySystemImage,
                             title: emptyTitle,
                             message: emptyMessage.map { Text($0) },
                             retry: retry)
        case .noInternet:
            StatePlaceholder(systemImage: "wifi.slash",
                             title: SwiftGen.Network.offline,
                             message: Text(SwiftGen.Network.reconnect),
                             retry: retry)
        case .error(let message):
            StatePlaceholder(systemImage: "exclamationmark.triangle",
                             title: SwiftGen.Network.loadFailed,
                             message: Text(verbatim: message),
                             retry: retry)
        }
    }
}

struct ViewModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewModeView(ViewMode<Int>.loading) { Text("\($0)") }
                .previewThemes("Загрузка")
            ViewModeView(ViewMode<Int>.content(42)) { Text("\($0)") }
                .previewThemes("Контент")
            ViewModeView(ViewMode<Int>.empty, emptyTitle: SwiftGen.Notifications.empty, retry: {}) { Text("\($0)") }
                .previewThemes("Пусто")
            ViewModeView(ViewMode<Int>.noInternet, retry: {}) { Text("\($0)") }
                .previewThemes("Нет сети")
            ViewModeView(ViewMode<Int>.error("Сервер недоступен"), retry: {}) { Text("\($0)") }
                .previewThemes("Ошибка")
        }
    }
}
