enum AccountChangeType: String, Identifiable {
    case password
    case email
    var id: String { rawValue }
}
