import Foundation

/// Небольшая модель нередко путает типы в JSON: отдаёт число строкой или наоборот.
/// Такие значения приводим к нужному типу, а не считаем ответ невалидным.
extension KeyedDecodingContainer {
    func decodeIfPresentLenientString(
        forKey key: Key
    ) throws -> String? {
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return String(value)
        }

        return nil
    }

    func decodeIfPresentLenientDouble(
        forKey key: Key
    ) throws -> Double? {
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return value
        }
        guard let value = try? decodeIfPresent(String.self, forKey: key) else { return nil }

        return Double(
            value
                .replacingOccurrences(of: ",", with: ".")
                .trimmingCharacters(in: .whitespaces)
        )
    }
}
