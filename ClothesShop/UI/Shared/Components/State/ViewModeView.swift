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
///
/// `placeholderHeader` показывается только над заглушками (загрузка, пусто, нет сети, ошибка).
/// Нужен, когда контент сам встраивает шапку, например в прокручиваемый список.
struct ViewModeView<Value, Content: View, PlaceholderHeader: View>: View {
    private let mode: ViewMode<Value>
    private let emptyTitle: String
    private let emptySystemImage: String
    private let emptyMessage: String?
    private let retry: (() -> Void)?
    private let placeholderHeader: PlaceholderHeader
    private let content: (Value) -> Content

    init(
        _ mode: ViewMode<Value>,
        emptyTitle: String = SwiftGen.Common.empty,
        emptySystemImage: String = "tray",
        emptyMessage: String? = nil,
        retry: (() -> Void)? = nil,
        @ViewBuilder placeholderHeader: () -> PlaceholderHeader,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.mode = mode
        self.emptyTitle = emptyTitle
        self.emptySystemImage = emptySystemImage
        self.emptyMessage = emptyMessage
        self.retry = retry
        self.placeholderHeader = placeholderHeader()
        self.content = content
    }

    var body: some View {
        if case .content(let value) = mode {
            content(value)
        } else {
            VStack(spacing: 15) {
                placeholderHeader
                placeholder
            }
        }
    }

    @ViewBuilder
    private var placeholder: some View {
        switch mode {
        case .loading, .content:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            StatePlaceholder(
                systemImage: emptySystemImage,
                title: emptyTitle,
                message: emptyMessage.map { Text($0) },
                retry: retry
            )
        case .noInternet:
            StatePlaceholder(
                systemImage: "wifi.slash",
                title: SwiftGen.Network.offline,
                message: Text(SwiftGen.Network.reconnect),
                retry: retry
            )
        case .error(let message):
            StatePlaceholder(
                systemImage: "exclamationmark.triangle",
                title: SwiftGen.Network.loadFailed,
                message: Text(verbatim: message),
                retry: retry
            )
        }
    }
}

extension ViewModeView where PlaceholderHeader == EmptyView {
    init(
        _ mode: ViewMode<Value>,
        emptyTitle: String = SwiftGen.Common.empty,
        emptySystemImage: String = "tray",
        emptyMessage: String? = nil,
        retry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.init(
            mode,
            emptyTitle: emptyTitle,
            emptySystemImage: emptySystemImage,
            emptyMessage: emptyMessage,
            retry: retry,
            placeholderHeader: { EmptyView() },
            content: content
        )
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
