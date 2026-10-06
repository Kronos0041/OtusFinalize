import Foundation
import Observation

@MainActor
@Observable
final class NotificationsViewModel {
    private(set) var mode: ViewMode<[Notification]> = .loading
    private(set) var readIDs: Set<String>

    var unreadCount: Int { (mode.content ?? []).filter(isUnread).count }

    private let getNotificationsUseCase: GetNotificationsUseCase
    private let getReadIDsUseCase: GetReadNotificationIDsUseCase
    private let markReadUseCase: MarkNotificationReadUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    @ObservationIgnored private var requestInFlight = false
    @ObservationIgnored private var connectivityTask: Task<Void, Never>?
    #if DEBUG
    @ObservationIgnored private var isPreview = false
    #endif

    init(getNotificationsUseCase: GetNotificationsUseCase,
         getReadIDsUseCase: GetReadNotificationIDsUseCase,
         markReadUseCase: MarkNotificationReadUseCase,
         connectivityUseCase: ObserveConnectivityUseCase) {
        self.getNotificationsUseCase = getNotificationsUseCase
        self.getReadIDsUseCase = getReadIDsUseCase
        self.markReadUseCase = markReadUseCase
        self.connectivityUseCase = connectivityUseCase
        readIDs = getReadIDsUseCase.execute()
        connectivityTask = Task { [weak self, updates = connectivityUseCase.execute()] in
            for await connected in updates where connected {
                self?.reloadAfterReconnect()
            }
        }
    }

    deinit {
        connectivityTask?.cancel()
    }

    #if DEBUG
    func applyPreview(items: [Notification], readIDs: Set<String> = []) {
        isPreview = true
        self.readIDs = readIDs
        mode = items.isEmpty ? .empty : .content(items)
    }
    #endif

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
        #if DEBUG
        if isPreview {
            readIDs.insert(item.id)
            return
        }
        #endif
        readIDs = markReadUseCase.execute(notificationID: item.id, currentIDs: readIDs)
    }

    private func load() async {
        #if DEBUG
        if isPreview { return }
        #endif
        guard !requestInFlight else { return }
        guard connectivityUseCase.isConnected else {
            if mode.content == nil { mode = .noInternet }
            return
        }
        if mode.content == nil { mode = .loading }
        requestInFlight = true
        defer { requestInFlight = false }
        do {
            let items = try await getNotificationsUseCase.execute()
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
