import Foundation

extension Date {
    func localized(
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}
