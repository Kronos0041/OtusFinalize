import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    private(set) var mode: ViewMode<UserProfile> = .loading
    private(set) var user: UserProfile
    var currentPassword = ""
    var newPassword = ""
    var repeatPassword = ""
    var newEmail = ""
    private(set) var isSubmitting = false
    private(set) var isRefreshing = false
    private(set) var formError: String?
    private(set) var profileError: String?
    private(set) var signOutError: String?
    var successMessage: String?

    private let profileUseCases: ProfileUseCases
    private let signOutUseCase: SignOutUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    private let validator: AuthInputValidator
    @ObservationIgnored private var connectivityTask: Task<Void, Never>?

    init(profileUseCases: ProfileUseCases,
         signOutUseCase: SignOutUseCase,
         connectivityUseCase: ObserveConnectivityUseCase,
         validator: AuthInputValidator = AuthInputValidator()) {
        self.profileUseCases = profileUseCases
        self.signOutUseCase = signOutUseCase
        self.connectivityUseCase = connectivityUseCase
        self.validator = validator
        user = profileUseCases.get.currentProfile
        connectivityTask = Task { [weak self, updates = connectivityUseCase.execute()] in
            for await connected in updates where connected {
                if case .noInternet = self?.mode { self?.loadProfile() }
            }
        }
    }

    deinit {
        connectivityTask?.cancel()
    }

    func loadProfile() {
        guard !isRefreshing, !isSubmitting else { return }
        guard connectivityUseCase.isConnected else {
            profileError = SwiftGen.Network.offline
            if mode.content == nil { mode = .noInternet }
            return
        }
        user = profileUseCases.get.currentProfile
        if mode.content == nil { mode = .loading }
        isRefreshing = true
        Task { [weak self] in await self?.performLoadProfile() }
    }

    func resetForm() {
        currentPassword = ""
        newPassword = ""
        repeatPassword = ""
        newEmail = ""
        formError = nil
    }

    /// Отправляет изменение аккаунта. Возвращает `true` при успехе — экран можно закрыть.
    func submit(_ change: AccountChangeType) async -> Bool {
        guard !isSubmitting, !isRefreshing else { return false }
        newEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = validationError(for: change) {
            formError = error
            return false
        }
        formError = nil
        isSubmitting = true
        defer { isSubmitting = false }
        let submittedEmail = newEmail
        do {
            switch change {
            case .password:
                try await profileUseCases.changePassword.execute(currentPassword: currentPassword, newPassword: newPassword)
            case .email:
                try await profileUseCases.changeEmail.execute(email: submittedEmail, currentPassword: currentPassword)
            }
            resetForm()
            successMessage = change == .password
                ? SwiftGen.Profile.passwordChanged
                : SwiftGen.Profile.confirmNewEmail(submittedEmail)
            return true
        } catch {
            formError = AuthErrorMessageMapper.message(for: error)
            return false
        }
    }

    func signOut() {
        guard !isSubmitting else { return }
        do {
            try signOutUseCase.execute()
            resetForm()
            signOutError = nil
        } catch {
            signOutError = AuthErrorMessageMapper.message(for: error)
        }
    }

    // MARK: - Асинхронные сценарии

    private func performLoadProfile() async {
        defer { isRefreshing = false }
        do {
            let profile = try await profileUseCases.get.execute()
            user = profile
            profileError = nil
            mode = profile.email.isEmpty ? .empty : .content(profile)
        } catch {
            let message = AuthErrorMessageMapper.message(for: error)
            profileError = message
            if mode.content == nil {
                mode = error as? ConnectivityError == .offline ? .noInternet : .error(message)
            }
        }
    }

    private func validationError(for change: AccountChangeType) -> String? {
        guard !currentPassword.isEmpty else { return SwiftGen.Profile.Error.currentPasswordRequired }
        switch change {
        case .password:
            guard newPassword.count >= 6 else { return SwiftGen.Profile.Error.passwordTooShort }
            guard newPassword == repeatPassword else { return SwiftGen.Auth.Error.passwordMismatch }
            guard newPassword != currentPassword else { return SwiftGen.Profile.Error.samePassword }
        case .email:
            guard validator.isValidEmail(newEmail) else { return SwiftGen.Auth.Error.invalidEmail }
            guard newEmail.caseInsensitiveCompare(user.email) != .orderedSame else {
                return SwiftGen.Profile.Error.sameEmail
            }
        }
        return nil
    }
}
