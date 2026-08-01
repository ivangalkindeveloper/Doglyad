import Foundation

/// Small models regularly wrap the answer in a code block or add a preamble,
/// despite the prompt forbidding it. Extract exactly the JSON object from the answer.
enum DExaminationJSONSanitizer {
    static func extractJSONObject(
        from response: String
    ) -> String? {
        let unwrapped = stripCodeFence(response)
        guard let start = unwrapped.firstIndex(of: "{") else { return nil }
        guard let end = findMatchingBrace(in: unwrapped, from: start) else { return nil }

        return String(unwrapped[start ... end])
    }

    private static func stripCodeFence(
        _ response: String
    ) -> String {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("```") else { return trimmed }

        var lines = trimmed.components(separatedBy: .newlines)
        lines.removeFirst()
        if let lastIndex = lines.lastIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("```") }) {
            lines.removeSubrange(lastIndex ..< lines.endIndex)
        }

        return lines.joined(separator: "\n")
    }

    /// A brace may occur inside a string value, so depth is counted only outside
    /// string literals, and escaped characters are skipped.
    private static func findMatchingBrace(
        in text: String,
        from start: String.Index
    ) -> String.Index? {
        var depth = 0
        var isInsideString = false
        var isEscaped = false
        var index = start

        while index < text.endIndex {
            let character = text[index]

            if isEscaped {
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "\"" {
                isInsideString.toggle()
            } else if !isInsideString {
                if character == "{" {
                    depth += 1
                } else if character == "}" {
                    depth -= 1
                    if depth == 0 {
                        return index
                    }
                }
            }

            index = text.index(after: index)
        }

        return nil
    }
}
