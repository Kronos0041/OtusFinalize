import FirebaseCore

/// Настраивает Firebase один раз за запуск процесса.
/// Повторный вызов безопасен: в превью и в тестах контейнер может создаваться несколько раз.
enum FirebaseConfigurator {
    static func configure() {
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()
    }
}
