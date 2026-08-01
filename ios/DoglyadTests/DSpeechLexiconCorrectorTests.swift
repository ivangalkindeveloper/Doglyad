import DoglyadSpeech
import Testing

/// The corrector substitutes words in a medical report, so its safety properties are
/// pinned down by tests: it must repair homophones and must refuse to substitute
/// anywhere the substitution could invert the meaning.
struct DSpeechLexiconCorrectorTests {
    /// A sample of the real examination dictionary, including every dangerous pair:
    /// opposites differing by a prefix or a couple of letters.
    private static let terms = [
        "анэхогенное образование",
        "гиперэхогенное образование",
        "гипоэхогенное образование",
        "изоэхогенное образование",
        "дистальное усиление сигнала",
        "капсула не изменена",
        "капсула прослеживается",
        "кальцинаты визуализируются",
        "кальцинаты не определяются",
        "контуры ровные",
        "контуры неровные",
        "контуры четкие",
        "контуры нечеткие",
        "содержимое однородное",
        "содержимое неоднородное",
        "структура однородная",
        "структура неоднородная",
        "эхогенность повышена",
        "эхогенность снижена",
        "васкуляризация усилена",
        "васкуляризация снижена",
        "асцит не определяется",
    ]

    private let corrector = DSpeechLexiconCorrector(terms: terms)

    // MARK: - Repairs what it was built for

    @Test("Созвучие э/е приводится к каноническому термину")
    func correctsPhoneticVariant() {
        #expect(
            corrector.correct("анехогенное образование в правой доле")
                == "анэхогенное образование в правой доле"
        )
    }

    @Test("Пропущенный слог в середине фразы восстанавливается")
    func correctsMissingSyllable() {
        #expect(
            corrector.correct("дистальное усилие сигнала определяется")
                == "дистальное усиление сигнала определяется"
        )
    }

    @Test("Длинный термин выигрывает у вложенного короткого")
    func prefersLongerTerm() {
        #expect(
            corrector.correct("дистальное усиление сигнала")
                == "дистальное усиление сигнала"
        )
    }

    // MARK: - Refuses where a substitution changes the meaning

    @Test("Отрицание не дописывается к фразе, где его не было")
    func neverAddsNegation() {
        #expect(corrector.correct("капсула изменена") == "капсула изменена")
    }

    @Test("Отрицание не убирается из фразы, где оно было")
    func neverRemovesNegation() {
        #expect(corrector.correct("капсула не изменена") == "капсула не изменена")
    }

    @Test(
        "Противоположности с приставкой не подменяются друг другом",
        arguments: [
            "содержимое однородное",
            "содержимое неоднородное",
            "структура однородная",
            "структура неоднородная",
            "контуры ровные",
            "контуры неровные",
            "контуры четкие",
            "контуры нечеткие",
        ]
    )
    func keepsPrefixedOpposites(term: String) {
        #expect(corrector.correct(term) == term)
    }

    @Test(
        "Противоположности без приставки не подменяются друг другом",
        arguments: [
            "эхогенность повышена",
            "эхогенность снижена",
            "васкуляризация усилена",
            "васкуляризация снижена",
        ]
    )
    func keepsOpposites(term: String) {
        #expect(corrector.correct(term) == term)
    }

    @Test("Близкие типы образований не подменяются друг другом")
    func keepsEchogenicityFamily() {
        for term in [
            "анэхогенное образование",
            "гиперэхогенное образование",
            "гипоэхогенное образование",
            "изоэхогенное образование",
        ] {
            #expect(corrector.correct(term) == term)
        }
    }

    @Test("Фразы с числами не трогаются: датчик 7,5 и 5 мегагерц — разные")
    func keepsPhrasesWithNumbers() {
        let text = "использован датчик 7,5 мегагерц линейный"
        #expect(corrector.correct(text) == text)
    }

    // MARK: - Does not damage ordinary speech

    @Test(
        "Речь вне словаря остаётся нетронутой",
        arguments: [
            "жалобы на боли в правом подреберье",
            "печень увеличена в размерах",
            "пациент иван мужчина рост метр семьдесят четыре",
            "сохранено двенадцать снимков и три видео",
        ]
    )
    func keepsUnrelatedSpeech(text: String) {
        #expect(corrector.correct(text) == text)
    }

    @Test("Пустой словарь превращает корректор в тождественную функцию")
    func emptyLexiconIsIdentity() {
        let empty = DSpeechLexiconCorrector(terms: [])
        #expect(empty.correct("анехогенное образование") == "анехогенное образование")
    }

    @Test("Пустой текст не ломает корректор")
    func handlesEmptyText() {
        #expect(corrector.correct("") == "")
    }

    @Test("Регистр первой буквы сохраняется при подмене")
    func preservesLeadingCase() {
        #expect(
            corrector.correct("Анехогенное образование в левой доле")
                == "Анэхогенное образование в левой доле"
        )
    }

    // MARK: - General safety property

    /// The key property: a single corruption of a term by a recognition error leads
    /// either to restoring the original term or to leaving the text as is — but never
    /// to turning one dictionary term into another.
    @Test("Порча термина никогда не превращает его в другой термин")
    func neverFlipsOneTermIntoAnother() {
        let vocabulary = Set(Self.terms)

        for term in Self.terms {
            for corrupted in Self.corruptions(of: term) {
                let result = corrector.correct(corrupted)
                guard result != term else { continue }

                #expect(
                    !vocabulary.contains(result),
                    "«\(corrupted)» превратилось в «\(result)» вместо «\(term)»"
                )
            }
        }
    }

    /// Corruptions imitating a recognition error: a dropped letter, a swap of adjacent
    /// letters, and a vowel substitution.
    private static func corruptions(
        of term: String
    ) -> [String] {
        var results: [String] = []

        for word in term.split(separator: " ") where word.count > 4 {
            let characters = Array(word)
            for index in 1 ..< (characters.count - 1) {
                var dropped = characters
                dropped.remove(at: index)
                results.append(term.replacingOccurrences(of: String(word), with: String(dropped)))

                var swapped = characters
                swapped.swapAt(index, index + 1)
                results.append(term.replacingOccurrences(of: String(word), with: String(swapped)))

                var replaced = characters
                replaced[index] = "о"
                results.append(term.replacingOccurrences(of: String(word), with: String(replaced)))
            }
        }

        return results
    }
}
