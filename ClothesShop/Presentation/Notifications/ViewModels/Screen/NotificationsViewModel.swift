
import Combine
import Foundation

final class NotificationsViewModel: ObservableObject {
    @Published private(set) var mode: ViewMode<[Notification]> = .loading
    @Published private(set) var readIDs: Set<String>

    var unreadCount: Int { (mode.content ?? []).filter(isUnread).count }

    private let getNotificationsUseCase: GetNotificationsUseCase
    private let getReadIDsUseCase: GetReadNotificationIDsUseCase
    private let markReadUseCase: MarkNotificationReadUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    private var requestInFlight = false
    private var observation: ObservationToken?
    #if DEBUG
    private var isPreview = false
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
        observation = connectivityUseCase.execute { [weak self] connected in
            if connected { self?.reloadAfterReconnect() }
        }
    }

    #if DEBUG
    func applyPreview(items: [Notification], readIDs: Set<String> = []) {
        isPreview = true; self.readIDs = readIDs
        mode = items.isEmpty ? .empty : .content(items)
    }
    #endif

    func reload(completion: (() -> Void)? = nil) {
        #if DEBUG
        if isPreview { completion?(); return }
        #endif
        guard !requestInFlight else { completion?(); return }
        guard connectivityUseCase.isConnected else {
            if mode.content == nil { mode = .noInternet }; completion?(); return
        }
        if mode.content == nil { mode = .loading }
        requestInFlight = true
        getNotificationsUseCase.execute { [weak self] result in
            self?.requestInFlight = false
            if case .failure = result, self?.mode.content != nil { completion?(); return }
            let sorted = result.map { $0.sorted { $0.remoteID < $1.remoteID } }
            self?.mode = .make(from: sorted) { $0.isEmpty }
            completion?()
        }
    }

    func refresh() async {
        await withCheckedContinuation { continuation in reload { continuation.resume() } }
    }

    func isUnread(_ item: Notification) -> Bool { !readIDs.contains(item.id) }

    func markRead(_ item: Notification) {
        guard isUnread(item) else { return }
        #if DEBUG
        if isPreview { readIDs.insert(item.id); return }
        #endif
        readIDs = markReadUseCase.execute(notificationID: item.id, currentIDs: readIDs)
    }

    private func reloadAfterReconnect() {
        switch mode {
        case .noInternet, .error: reload()
        case .loading, .content, .empty: break
        }
    }
}
