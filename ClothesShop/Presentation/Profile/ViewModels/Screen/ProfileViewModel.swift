

import Combine
import Foundation

final class ProfileViewModel: ObservableObject {
    @Published private(set) var mode: ViewMode<UserProfile> = .loading
    @Published private(set) var user: UserProfile
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

    private let getProfileUseCase: GetProfileUseCase
    private let changePasswordUseCase: ChangePasswordUseCase
    private let changeEmailUseCase: ChangeEmailUseCase
    private let signOutUseCase: SignOutUseCase
    private let connectivityUseCase: ObserveConnectivityUseCase
    private var observation: ObservationToken?
    #if DEBUG
    private var isPreview = false
    #endif

    init(getProfileUseCase: GetProfileUseCase,
         changePasswordUseCase: ChangePasswordUseCase,
         changeEmailUseCase: ChangeEmailUseCase,
         signOutUseCase: SignOutUseCase,
         connectivityUseCase: ObserveConnectivityUseCase) {
        self.getProfileUseCase = getProfileUseCase
        self.changePasswordUseCase = changePasswordUseCase
        self.changeEmailUseCase = changeEmailUseCase
        self.signOutUseCase = signOutUseCase
        self.connectivityUseCase = connectivityUseCase
        user = getProfileUseCase.currentProfile
        observation = connectivityUseCase.execute { [weak self] connected in
            if connected, case .noInternet = self?.mode { self?.loadProfile() }
        }
    }

    #if DEBUG
    func applyPreview(profile: UserProfile) {
        isPreview = true; user = profile; mode = .content(profile)
    }
    #endif

    func loadProfile() {
        #if DEBUG
        if isPreview { return }
        #endif
        guard !isRefreshing, !isSubmitting else { return }
        guard connectivityUseCase.isConnected else {
            profileError = SwiftGen.Network.offline
            if mode.content == nil { mode = .noInternet }
            return
        }
        user = getProfileUseCase.currentProfile
        if mode.content == nil { mode = .loading }
        isRefreshing = true
        getProfileUseCase.execute { [weak self] result in
            guard let self else { return }
            self.isRefreshing = false
            switch result {
            case .success(let profile):
                self.user = profile; self.profileError = nil
                self.mode = profile.email.isEmpty ? .empty : .content(profile)
            case .failure(let error):
                let message = AuthErrorMessageMapper.message(for: error)
                self.profileError = message
                if self.mode.content == nil {
                    self.mode = error is ConnectivityError ? .noInternet : .error(message)
                }
            }
        }
    }

    func resetForm() {
        currentPassword = ""; newPassword = ""; repeatPassword = ""; newEmail = ""; formError = nil
    }

    func submit(_ change: AccountChangeType, completion: @escaping () -> Void) {
        guard !isSubmitting, !isRefreshing else { return }
        newEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = validationError(for: change) { formError = error; return }
        formError = nil
        #if DEBUG
        if isPreview { resetForm(); completion(); return }
        #endif
        isSubmitting = true
        let submittedEmail = newEmail
        let resultHandler: (Result<Void, Error>) -> Void = { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success:
                self.resetForm(); completion()
                self.successMessage = change == .password
                    ? SwiftGen.Profile.passwordChanged : SwiftGen.Profile.confirmNewEmail(submittedEmail)
            case .failure(let error): self.formError = AuthErrorMessageMapper.message(for: error)
            }
        }
        switch change {
        case .password:
            changePasswordUseCase.execute(currentPassword: currentPassword,
                                          newPassword: newPassword, completion: resultHandler)
        case .email:
            changeEmailUseCase.execute(email: submittedEmail,
                                       currentPassword: currentPassword, completion: resultHandler)
        }
    }

    func signOut() {
        #if DEBUG
        if isPreview { return }
        #endif
        guard !isSubmitting else { return }
        do { try signOutUseCase.execute(); resetForm(); signOutError = nil }
        catch { signOutError = AuthErrorMessageMapper.message(for: error) }
    }

    private func validationError(for change: AccountChangeType) -> String? {
        guard !currentPassword.isEmpty else { return SwiftGen.Profile.Error.currentPasswordRequired }
        switch change {
        case .password:
            guard newPassword.count >= 6 else { return SwiftGen.Profile.Error.passwordTooShort }
            guard newPassword == repeatPassword else { return SwiftGen.Auth.Error.passwordMismatch }
            guard newPassword != currentPassword else { return SwiftGen.Profile.Error.samePassword }
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
