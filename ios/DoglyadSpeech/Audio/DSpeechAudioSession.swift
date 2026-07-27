import AVFoundation
import Foundation

/// Откуда сейчас идёт звук. От этого зависят и настройки сессии, и подсказки
/// распознавателю: гарнитура ловит речь у рта, встроенный микрофон — с
/// расстояния и через шум кабинета.
public enum DSpeechAudioRoute {
    /// Гарнитура: AirPods, проводная петличка, USB-микрофон.
    case headset
    /// Встроенный микрофон: телефон в руке или лежит рядом на аппарате.
    case builtIn
}

/// Настройка аудиосессии под диктовку осмотра.
enum DSpeechAudioSession {
    /// Готовит сессию и возвращает фактический маршрут входа.
    ///
    /// Категория именно `.playAndRecord`, хотя мы ничего не воспроизводим.
    /// Голосовая обработка поднимается сразу на паре узлов ввода и вывода —
    /// включение на одном автоматически включает её на другом. На `.record`
    /// выходного узла нет, поэтому входной остаётся ненастроенным и отдаёт
    /// формат с нулевой частотой, на котором `installTap` падает по
    /// `IsFormatSampleRateAndChannelCountValid`. По той же причине категорию с
    /// выводом требует и высококачественная запись с Bluetooth-гарнитуры.
    ///
    /// Режим `.default`, а не `.measurement`: последний выключает всю системную
    /// обработку сигнала, а для диктовки с расстояния она нам как раз нужна.
    /// Он же единственный совместим с `bluetoothHighQualityRecording`.
    @discardableResult
    static func activate() throws -> DSpeechAudioRoute {
        let session = AVAudioSession.sharedInstance()

        // HFP включаем всегда: узкая полоса здесь не помеха — распознаватели и
        // так работают на 16 кГц, а микрофон у рта бьёт любой встроенный.
        var options: AVAudioSession.CategoryOptions = [
            .duckOthers,
            .allowBluetoothHFP,
            // Мы ничего не играем, но без этого вывод уходит на разговорный
            // динамик, а вместе с ним меняется и выбор микрофона.
            .defaultToSpeaker,
        ]
        if #available(iOS 26.0, *) {
            // Совместимые AirPods пишут в полной полосе; если маршрут не тянет,
            // система сама откатится на HFP.
            options.insert(.bluetoothHighQualityRecording)
        }

        // Ошибки здесь глушить нельзя: после неудачной настройки входной узел
        // отдаёт невалидный формат, и падение случается уже далеко от причины.
        try session.setCategory(.playAndRecord, mode: .default, options: options)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        // Входящий звонок посреди диктовки обрывает запись, а осмотр придётся
        // начинать заново — просим систему не прерывать нас своими сигналами.
        try? session.setPrefersNoInterruptionsFromSystemAlerts(true)

        return currentRoute
    }

    static func deactivate() {
        let session = AVAudioSession.sharedInstance()
        try? session.setPrefersNoInterruptionsFromSystemAlerts(false)
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Микрофон считаем встроенным, только если других входов нет: всё
    /// остальное — гарнитура, петличка, USB — заведомо ближе ко рту врача.
    static var currentRoute: DSpeechAudioRoute {
        let inputs = AVAudioSession.sharedInstance().currentRoute.inputs
        let isBuiltIn = inputs.allSatisfy { $0.portType == .builtInMic }

        return isBuiltIn ? .builtIn : .headset
    }
}

extension AVAudioFormat {
    /// `installTap` падает по ассерту на формате с нулевой частотой или без
    /// каналов. Такой отдаёт входной узел, если сессия не поднялась, нет
    /// разрешения на микрофон или узел ещё не перестроился после включения
    /// голосовой обработки.
    var isValidForCapture: Bool {
        sampleRate > 0 && channelCount > 0
    }
}
