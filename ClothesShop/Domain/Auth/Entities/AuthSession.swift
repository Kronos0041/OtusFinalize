enum AuthSession: Equatable {
    case signedOut
    case awaitingEmailVerification(String)
    case verified
}
