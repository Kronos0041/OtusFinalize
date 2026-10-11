import Foundation

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "\u{00A0}"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func string(from rubles: Int) -> String {
        let number = formatter.string(from: NSNumber(value: rubles)) ?? "\(rubles)"
        return "\(number)\u{00A0}₽"
    }
}
