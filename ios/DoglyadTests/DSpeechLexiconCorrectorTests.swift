import DoglyadSpeech
import Testing

/// Корректор подменяет слова в медицинском заключении, поэтому его безопасные
/// свойства зафиксированы тестами: он обязан чинить созвучия и обязан
/// отказываться от подмены везде, где та могла бы перевернуть смысл.
struct DSpeechLexiconCorrectorTests {
    /// Выборка из реального словаря осмотра, включая все опасные пары:
    /// противоположности, отличающиеся приставкой или парой букв.
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

    // MARK: - Чинит то, ради чего затевался

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

    // MARK: - Отказывается там, где подмена меняет смысл

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

    // MARK: - Не портит обычную речь

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

    // MARK: - Общее свойство безопасности

    /// Главное свойство: одна порча термина ошибкой распознавания приводит либо
    /// к восстановлению исходного термина, либо к тому, что текст оставят как
    /// есть — но никогда к превращению термина в другой термин словаря.
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

    /// Порчи, имитирующие ошибку распознавания: пропуск буквы, перестановка
    /// соседних и подмена гласной.
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
