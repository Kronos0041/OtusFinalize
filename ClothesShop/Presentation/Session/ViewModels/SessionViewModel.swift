import Foundation
import Observation

/// Состояние сессии на всё время работы приложения: вошёл, ждёт подтверждения почты или вышел.
/// Данных форм входа здесь нет: они живут в `AuthViewModel`, которая создаётся заново на каждый показ входа.
@MainActor
@Observable
final class SessionViewModel {
    private(set) var session: AuthSession

    var isSignedIn: Bool { session == .verified }

    var pendingEmail: String? {
        guard case .awaitingEmailVerification(let email) = session else { return nil }
        return email
    }

    private let observeSessionUseCase: ObserveAuthSessionUseCase
    @ObservationIgnored private var observation: ObservationToken?

    init(observeSessionUseCase: ObserveAuthSessionUseCase) {
        self.observeSessionUseCase = observeSessionUseCase
        session = observeSessionUseCase.currentSession
    }

    /// Вход, регистрация и выход приходят сюда из Firebase сами.
    func observeSession() {
        guard observation == nil else { return }
        observation = observeSessionUseCase.observeSession { [weak self] in self?.session = $0 }
    }

    /// Подтверждение почты Firebase о смене сессии не сообщает: экран подтверждения говорит об этом сам.
    func markEmailVerified() {
        session = .verified
    }
}
