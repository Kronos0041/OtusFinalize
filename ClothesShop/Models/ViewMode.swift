//
//  ViewMode.swift
//  ClothesShop
//
//  Created by Alex on 29.09.2026.
//

import Foundation

/// Что показывает экран, который загружает данные с сервера.
/// ViewModel выставляет режим по ответу бэкенда, View делает `switch` через `ViewModeView`.
enum ViewMode<Content> {
    /// Первая загрузка — данных ещё нет.
    case loading
    /// Есть данные — показываем контент.
    case content(Content)
    /// Сервер ответил, но данных нет.
    case empty
    /// Нет подключения к интернету.
    case noInternet
    /// Сервер вернул ошибку. Текст — для пользователя.
    case error(String)

    var content: Content? {
        if case .content(let content) = self { return content }
        return nil
    }
}

extension ViewMode {
    /// Единое правило разбора ответа: пусто / контент / нет сети / ошибка.
    static func make(from result: Result<Content, Error>, isEmpty: (Content) -> Bool) -> ViewMode {
        switch result {
        case .success(let value):
            return isEmpty(value) ? .empty : .content(value)
        case .failure(let error):
            return error.isConnectivityError ? .noInternet : .error(error.localizedDescription)
        }
    }
}

extension Error {
    /// Ошибка из-за отсутствия связи, а не из-за сервера.
    var isConnectivityError: Bool {
        let error = self as NSError
        switch error.domain {
        case NSURLErrorDomain:
            return [NSURLErrorNotConnectedToInternet,
                    NSURLErrorNetworkConnectionLost,
                    NSURLErrorTimedOut,
                    NSURLErrorCannotConnectToHost,
                    NSURLErrorDataNotAllowed].contains(error.code)
        case "FIRFirestoreErrorDomain":
            return error.code == 14 // FirestoreErrorCode.unavailable
        case "FIRAuthErrorDomain":
            return error.code == 17020 // AuthErrorCode.networkError
        default:
            return false
        }
    }
}
