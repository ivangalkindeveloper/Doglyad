import Foundation

/// Приводит распознанный текст к канонической лексике осмотра.
///
/// Распознаватель ошибается на созвучиях: «анехогенное» вместо «анэхогенное»,
/// «дистальное усилие» вместо «дистальное усиление». Такие промахи модель
/// разбора уже не починит — она не знает, что было сказано на самом деле.
/// Поэтому перед разбором прогоняем текст по словарю терминов и подменяем
/// близкие совпадения на канонические.
///
/// Сравниваем не буквы, а «фонетический скелет»: ошибки распознавания слышимые,
/// а не орфографические, и «э» с «е» для него взаимозаменяемы.
///
/// Две подмены запрещены жёстко, потому что переворачивают смысл заключения:
/// алгоритм никогда не добавляет и не убирает отрицание и не трогает фразы с
/// числами. «Капсула изменена» и «капсула не изменена» отличаются на три
/// правки, а означают противоположное; «7,5 мегагерц» и «5 мегагерц» — на две,
/// а датчик при этом разный.
public struct DSpeechLexiconCorrector: Sendable {
    /// Допустимая доля правок от длины термина. Взята консервативно: пропустить
    /// ошибку дешевле, чем подменить то, что врач действительно сказал.
    private static let maximumDistanceRatio = 0.16

    /// Насколько лучший кандидат должен опережать следующего, чтобы подмена
    /// состоялась.
    ///
    /// Словарь осмотра почти целиком состоит из смысловых противоположностей,
    /// отличающихся парой букв: «содержимое однородное» и «неоднородное»,
    /// «эхогенность повышена» и «снижена», «васкуляризация усилена» и
    /// «снижена», «гипо-», «гипер-», «изо-» и «анэхогенное образование».
    /// Все эти пары укладываются в порог расстояния, поэтому одного лишь
    /// отказа от ничьих мало — нужен запас. На прогоне по всему словарю с
    /// искусственными ошибками распознавания запас в две правки полностью
    /// убирает подмену одного термина другим, теряя около процента починок.
    private static let minimumMargin = 2

    private struct Term: Sendable {
        let text: String
        let normalized: [Character]
        let hasNegation: Bool
    }

    /// Термины разложены по числу слов: окно текста сравниваем только с
    /// терминами такой же длины.
    private let termsByWordCount: [Int: [Term]]
    private let maximumWordCount: Int

    public init(
        terms: [String]
    ) {
        var grouped: [Int: [Term]] = [:]

        for text in terms {
            let wordCount = text.split(separator: " ").count
            // Односложных терминов в словаре нет, и это к лучшему: на коротком
            // слове порог расстояния ловит слишком много чужого.
            guard wordCount > 1 else { continue }

            let normalized = Self.normalize(text)
            guard !normalized.isEmpty else { continue }

            grouped[wordCount, default: []].append(
                Term(
                    text: text,
                    normalized: normalized,
                    hasNegation: Self.hasNegation(text)
                )
            )
        }

        termsByWordCount = grouped
        maximumWordCount = grouped.keys.max() ?? 0
    }

    public func correct(
        _ text: String
    ) -> String {
        guard maximumWordCount > 1 else { return text }

        let words = text.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !words.isEmpty else { return text }

        // Замена, начинающаяся в позиции индекса, и сколько слов она поглощает.
        var replacements = [(text: String, length: Int)?](repeating: nil, count: words.count)
        var isConsumed = [Bool](repeating: false, count: words.count)

        // Длинные фразы идут первыми: «дистальное усиление сигнала» должно
        // выиграть у вложенного в него более короткого термина.
        for wordCount in stride(from: maximumWordCount, through: 2, by: -1) {
            guard let candidates = termsByWordCount[wordCount] else { continue }
            guard words.count >= wordCount else { continue }

            for start in 0 ... (words.count - wordCount) {
                let range = start ..< (start + wordCount)
                guard !isConsumed[range].contains(true) else { continue }

                let window = words[range].joined(separator: " ")
                guard let match = bestMatch(for: window, among: candidates) else { continue }

                replacements[start] = (Self.matchingCase(of: window, for: match), wordCount)
                for index in range {
                    isConsumed[index] = true
                }
            }
        }

        var result: [String] = []
        result.reserveCapacity(words.count)
        var index = 0
        while index < words.count {
            if let replacement = replacements[index] {
                result.append(replacement.text)
                index += replacement.length
            } else {
                result.append(words[index])
                index += 1
            }
        }

        return result.joined(separator: " ")
    }

    /// Ближайший термин, если он достаточно близко и заметно ближе остальных.
    private func bestMatch(
        for window: String,
        among candidates: [Term]
    ) -> String? {
        guard !window.contains(where: \.isNumber) else { return nil }

        let normalized = Self.normalize(window)
        guard !normalized.isEmpty else { return nil }

        let limit = Int((Double(normalized.count) * Self.maximumDistanceRatio).rounded())
        guard limit > 0 else { return nil }

        let hasNegation = Self.hasNegation(window)
        var best: Term?
        var bestDistance = Int.max
        var runnerUpDistance = Int.max

        for term in candidates {
            // Отрицание неприкосновенно: алгоритм не имеет права ни дописать
            // «не», ни убрать его.
            guard term.hasNegation == hasNegation else { continue }
            guard abs(term.normalized.count - normalized.count) <= limit else { continue }

            let distance = Self.distance(normalized, term.normalized, limit: limit)
            guard distance <= limit else { continue }

            if distance < bestDistance {
                runnerUpDistance = bestDistance
                bestDistance = distance
                best = term
            } else if distance < runnerUpDistance {
                runnerUpDistance = distance
            }
        }

        guard let best else { return nil }
        // Ближайший термин должен заметно опережать следующего — иначе это
        // выбор между смысловыми противоположностями, и гадать мы не будем.
        guard runnerUpDistance - bestDistance >= Self.minimumMargin else { return nil }

        return best.text
    }

    /// Свёртка созвучий: распознаватель ошибается на слух, поэтому убираем
    /// различия, которых на слух нет, — «э»/«е», «ы»/«и», звонкость согласных,
    /// мягкий и твёрдый знаки, удвоения и пробелы.
    private static let phoneticMap: [Character: Character] = [
        "ё": "е",
        "э": "е",
        "й": "и",
        "ы": "и",
        "б": "п",
        "в": "ф",
        "г": "к",
        "д": "т",
        "ж": "ш",
        "з": "с",
    ]

    private static func normalize(
        _ text: String
    ) -> [Character] {
        var result: [Character] = []
        result.reserveCapacity(text.count)

        for character in text.lowercased() {
            guard character.isLetter || character.isNumber else { continue }
            guard character != "ь", character != "ъ" else { continue }

            let mapped = phoneticMap[character] ?? character
            guard result.last != mapped else { continue }

            result.append(mapped)
        }

        return result
    }

    private static let negations: Set<String> = ["не", "нет", "без", "no", "not", "without"]

    private static func hasNegation(
        _ text: String
    ) -> Bool {
        text.lowercased()
            .split(whereSeparator: { !$0.isLetter })
            .contains { negations.contains(String($0)) }
    }

    /// Расстояние Левенштейна с ранним выходом: как только вся строка ушла
    /// дальше порога, считать остальное бессмысленно.
    private static func distance(
        _ lhs: [Character],
        _ rhs: [Character],
        limit: Int
    ) -> Int {
        guard !lhs.isEmpty else { return rhs.count }
        guard !rhs.isEmpty else { return lhs.count }

        var previous = Array(0 ... rhs.count)
        var current = [Int](repeating: 0, count: rhs.count + 1)

        for lhsIndex in 1 ... lhs.count {
            current[0] = lhsIndex
            var rowMinimum = current[0]

            for rhsIndex in 1 ... rhs.count {
                let cost = lhs[lhsIndex - 1] == rhs[rhsIndex - 1] ? 0 : 1
                current[rhsIndex] = min(
                    previous[rhsIndex] + 1,
                    current[rhsIndex - 1] + 1,
                    previous[rhsIndex - 1] + cost
                )
                rowMinimum = min(rowMinimum, current[rhsIndex])
            }

            guard rowMinimum <= limit else { return limit + 1 }

            swap(&previous, &current)
        }

        return previous[rhs.count]
    }

    /// Термины в словаре записаны со строчной буквы, а в тексте фраза могла
    /// начинать предложение — сохраняем регистр первой буквы.
    private static func matchingCase(
        of window: String,
        for replacement: String
    ) -> String {
        guard let first = window.first, first.isUppercase else { return replacement }

        return replacement.prefix(1).uppercased() + replacement.dropFirst()
    }
}
