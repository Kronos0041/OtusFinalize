//
//  ViewModeView.swift
//  ClothesShop
//
//  Created by Alex on 29.09.2026.
//

import SwiftUI

/// Показывает контент или заглушку в зависимости от `ViewMode`.
///
///     ViewModeView(viewModel.viewMode, emptyTitle: "Каталог пока пуст", retry: { viewModel.reload() }) { sections in
///         CatalogView(sections: sections)
///     }
struct ViewModeView<Value, Content: View>: View {
    private let mode: ViewMode<Value>
    private let emptyTitle: LocalizedStringKey
    private let retry: () -> Void
    private let content: (Value) -> Content

    init(_ mode: ViewMode<Value>,
         emptyTitle: LocalizedStringKey,
         retry: @escaping () -> Void,
         @ViewBuilder content: @escaping (Value) -> Content) {
        self.mode = mode
        self.emptyTitle = emptyTitle
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
            StatePlaceholder(systemImage: "tray",
                             title: emptyTitle,
                             retry: retry)
        case .noInternet:
            StatePlaceholder(systemImage: "wifi.slash",
                             title: "Нет подключения к интернету",
                             message: Text("Данные загрузятся автоматически, когда появится сеть."),
                             retry: retry)
        case .error(let message):
            StatePlaceholder(systemImage: "exclamationmark.triangle",
                             title: "Не удалось загрузить данные",
                             message: Text(verbatim: message),
                             retry: retry)
        }
    }
}

/// Заглушка «пусто / нет сети / ошибка» с кнопкой повтора.
struct StatePlaceholder: View {
    let systemImage: String
    let title: LocalizedStringKey
    var message: Text? = nil
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.appGray)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let message {
                message
                    .font(.footnote)
                    .foregroundColor(.appGray)
                    .multilineTextAlignment(.center)
            }

            if let retry {
                Button("Повторить", action: retry)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ViewModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewModeView(ViewMode<Int>.noInternet, emptyTitle: "Пусто", retry: {}) { Text("\($0)") }
            ViewModeView(ViewMode<Int>.error("Сервер недоступен"), emptyTitle: "Пусто", retry: {}) { Text("\($0)") }
            ViewModeView(ViewMode<Int>.empty, emptyTitle: "Уведомлений пока нет", retry: {}) { Text("\($0)") }
        }
    }
}
