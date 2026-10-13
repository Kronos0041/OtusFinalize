import Foundation
import Observation

/// Экран подтверждения почты. Живёт, пока этот экран на экране.
@MainActor
@Observable
final class EmailVerificationViewModel {
    let email: String
    private(set) var isSubmitting = false
    private(set) var toast: ToastMessage?

    private let resendUseCase: ResendVerificationEmailUseCase
    private let verifyEmailUseCase: VerifyEmailUseCase
    private let signOutUseCase: SignOutUseCase
    private let onVerified: () -> Void

    init(email: String,
         resendUseCase: ResendVerificationEmailUseCase,
         verifyEmailUseCase: VerifyEmailUseCase,
         signOutUseCase: SignOutUseCase,
         onVerified: @escaping () -> Void) {
        self.email = email
        self.resendUseCase = resendUseCase
        self.verifyEmailUseCase = verifyEmailUseCase
        self.signOutUseCase = signOutUseCase
        self.onVerified = onVerified
    }

    func dismissToast() {
        toast = nil
    }

    func resendVerificationEmail() {
        run { viewModel in
            try await viewModel.resendUseCase.resendVerificationEmail()
            viewModel.toast = .success(SwiftGen.Auth.Verification.resent)
        }
    }

    func refreshEmailVerification() {
        run { viewModel in
            if try await viewModel.verifyEmailUseCase.verifyEmail() {
                viewModel.onVerified()
            } else {
                viewModel.toast = .error(SwiftGen.Auth.Verification.notConfirmed)
            }
        }
    }

    /// Выход возвращает к вводу email: сессию обновит подписка в `SessionViewModel`.
    func signOut() {
        do {
            try signOutUseCase.signOut()
        } catch {
            toast = .error(AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false))
        }
    }

    private func run(_ operation: @escaping (EmailVerificationViewModel) async throws -> Void) {
        guard !isSubmitting else { return }
        isSubmitting = true
        toast = nil
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }
            do {
                try await operation(self)
            } catch {
                self.toast = .error(AuthErrorMessageMapper.message(for: error, verifyingCurrentPassword: false))
            }
        }
    }
}
