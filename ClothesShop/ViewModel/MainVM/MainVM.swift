import Foundation
import Combine

enum AccountChange: String, Identifiable {
    case password
    case email

    var id: String { rawValue }
}

/// Профиль и настройки учётной записи Firebase Auth.
final class MainViewModel: ObservableObject {
    @Published private(set) var viewMode: ViewMode<ProfileViewState> = .loading
    @Published private(set) var user: ProfileViewState
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var repeatPassword = ""
    @Published var newEmail = ""
    @Published private(set) var isSubmitting = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var formError: String?
    @Published private(set) var profileError: String?
    @Published private(set) var signOutError: String?
    @Published var successMessage: String?

    private let network: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    #if DEBUG
    private var isPreview = false

    convenience init(previewProfile: ProfileViewState) {
        self.init(profile: previewProfile)
        isPreview = true
        viewMode = .content(previewProfile)
    }
    #endif

    init(network: NetworkMonitor = .shared, profile: ProfileViewState? = nil) {
        self.network = network
        user = profile ?? AuthenticationService.profile
        network.$isConnected
            .removeDuplicates()
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self, case .noInternet = self.viewMode else { return }
                self.loadProfile()
            }
            .store(in: &cancellables)
    }

    func loadProfile() {
        #if DEBUG
        if isPreview { return }
        #endif
        guard !isRefreshing, !isSubmitting else { return }
        guard network.isConnected else {
            profileError = SwiftGen.Network.offline
            if viewMode.content == nil { viewMode = .noInternet }
            return
        }
        user = AuthenticationService.profile
        if viewMode.content == nil { viewMode = .loading }
        isRefreshing = true
        AuthenticationService.refreshProfile { [weak self] result in
            guard let self else { return }
            self.isRefreshing = false
            switch result {
            case .success(let profile):
                self.user = profile
                self.profileError = nil
                self.viewMode = profile.email.isEmpty ? .empty : .content(profile)
            case .failure(let error):
                self.profileError = AuthenticationService.accountErrorMessage(error)
                if self.viewMode.content == nil {
                    self.viewMode = error.isConnectivityError
                        ? .noInternet
                        : .error(AuthenticationService.accountErrorMessage(error))
                }
            }
        }
    }

    func resetForm() {
        currentPassword = ""
        newPassword = ""
        repeatPassword = ""
        newEmail = ""
        formError = nil
    }

    func submit(_ change: AccountChange, completion: @escaping () -> Void) {
        guard !isSubmitting, !isRefreshing else { return }
        newEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = validationError(for: change) {
            formError = error
            return
        }
        formError = nil
        #if DEBUG
        if isPreview {
            resetForm()
            completion()
            return
        }
        #endif
        isSubmitting = true
        let submittedEmail = newEmail
        let handleResult: AuthenticationService.Completion = { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success:
                self.resetForm()
                completion()
                self.successMessage = change == .password
                    ? SwiftGen.Profile.passwordChanged
                    : SwiftGen.Profile.confirmNewEmail(submittedEmail)
            case .failure(let error):
                self.formError = AuthenticationService.accountErrorMessage(error)
            }
        }
        switch change {
        case .password:
            AuthenticationService.changePassword(currentPassword: currentPassword,
                                                 newPassword: newPassword,
                                                 completion: handleResult)
        case .email:
            AuthenticationService.changeEmail(to: submittedEmail,
                                              currentPassword: currentPassword,
                                              completion: handleResult)
        }
    }

    /// Слушатель авторизации в LoadPreview возвращает экран входа.
    func signOut() {
        #if DEBUG
        if isPreview { return }
        #endif
        guard !isSubmitting else { return }
        do {
            try AuthenticationService.signOut()
            resetForm()
            signOutError = nil
        } catch {
            signOutError = AuthenticationService.accountErrorMessage(error)
        }
    }

    private func validationError(for change: AccountChange) -> String? {
        guard !currentPassword.isEmpty else { return SwiftGen.Profile.Error.currentPasswordRequired }
        switch change {
        case .password:
            guard newPassword.count >= 6 else {
                return SwiftGen.Profile.Error.passwordTooShort
            }
            guard newPassword == repeatPassword else { return SwiftGen.Auth.Error.passwordMismatch }
            guard newPassword != currentPassword else {
                return SwiftGen.Profile.Error.samePassword
            }
        case .email:
            let predicate = NSPredicate(format: "SELF MATCHES %@",
                                        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
            guard predicate.evaluate(with: newEmail) else { return SwiftGen.Auth.Error.invalidEmail }
            guard newEmail.caseInsensitiveCompare(user.email) != .orderedSame else {
                return SwiftGen.Profile.Error.sameEmail
            }
        }
        return nil
    }
}
