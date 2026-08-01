import Foundation

/// A small model often confuses JSON types: it returns a number as a string or the
/// other way round. Such values are coerced instead of failing the whole answer.
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
