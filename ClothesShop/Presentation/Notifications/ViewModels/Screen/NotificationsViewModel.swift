import Foundation
import Observation

@MainActor
@Observable
final class NotificationsViewModel {
    private(set) var mode: ViewMode<[Notification]> = .loading
    private(set) var readIDs: Set<String>

    var unreadCount: Int { (mode.content ?? []).filter(isUnread).count }

    private let notificationsUseCases: NotificationsUseCases
    private let connectivityUseCase: ObserveConnectivityUseCase
    @ObservationIgnored private var requestInFlight = false
    @ObservationIgnored private var connectivityTask: Task<Void, Never>?

    init(notificationsUseCases: NotificationsUseCases,
         connectivityUseCase: ObserveConnectivityUseCase) {
        self.notificationsUseCases = notificationsUseCases
        self.connectivityUseCase = connectivityUseCase
        readIDs = notificationsUseCases.readIDs.getReadNotificationIDs()
        connectivityTask = Task { [weak self, updates = connectivityUseCase.observeConnectivity()] in
            for await connected in updates where connected {
                self?.reloadAfterReconnect()
            }
        }
    }

    deinit {
        connectivityTask?.cancel()
    }

    func reload() {
        Task { [weak self] in await self?.load() }
    }

    /// Для pull-to-refresh: завершается вместе с загрузкой.
    func refresh() async {
        await load()
    }

    func isUnread(_ item: Notification) -> Bool {
        !readIDs.contains(item.id)
    }

    func markRead(_ item: Notification) {
        guard isUnread(item) else { return }
        readIDs = notificationsUseCases.markRead.markRead(notificationID: item.id, currentIDs: readIDs)
    }

    private func load() async {
        guard !requestInFlight else { return }
        guard connectivityUseCase.isConnected else {
            if mode.content == nil { mode = .noInternet }
            return
        }
        if mode.content == nil { mode = .loading }
        requestInFlight = true
        defer { requestInFlight = false }
        do {
            let items = try await notificationsUseCases.get.getNotifications()
            mode = .make(from: .success(items.sorted { $0.remoteID < $1.remoteID })) { $0.isEmpty }
        } catch {
            // Ошибка повторной загрузки не стирает уже показанный список.
            if mode.content == nil { mode = .make(from: .failure(error)) { $0.isEmpty } }
        }
    }

    private func reloadAfterReconnect() {
        switch mode {
        case .noInternet, .error: reload()
        case .loading, .content, .empty: break
        }
    }
}
