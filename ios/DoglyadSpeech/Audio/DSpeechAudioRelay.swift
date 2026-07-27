import AVFAudio
import Foundation
import Speech

/// Мост между микрофоном и распознавательной задачей `SFSpeechRecognizer`.
///
/// Решает две задачи, которые нельзя решить в контроллере:
///
/// 1. Тап `AVAudioEngine` вызывается на аудиопотоке, а задачу пересоздаёт главный
/// поток. Прямой доступ к текущему запросу из двух потоков — гонка: буфер мог
/// уйти в уже завершённый запрос. Здесь ссылка на запрос закрыта замком.
///
/// 2. Сервис сам финализирует задачу по лимиту длительности. Пока создаётся
/// новая, аудио идти некуда — речь за это окно терялась. Поэтому храним хвост
/// последних секунд и переливаем его в новый запрос при подключении.
final class DSpeechAudioRelay: @unchecked Sendable {
    /// Сколько аудио держим для перелива. Секунды хватает на окно пересоздания
    /// задачи, а больше — только дублирование уже распознанного текста.
    private static let replaySeconds: Double = 1.0

    private let lock = NSLock()
    private var request: SFSpeechAudioBufferRecognitionRequest?

    /// Кольцо предварительно выделенных буферов: аллокации на аудиопотоке
    /// приводят к пропускам звука, поэтому память берём один раз на старте.
    private var ring: [AVAudioPCMBuffer] = []
    private var ringWriteIndex = 0
    private var ringFilled = 0

    /// Выделяет кольцо под формат микрофона. Вызывать до установки тапа.
    func prepare(
        format: AVAudioFormat,
        bufferFrames: AVAudioFrameCount
    ) {
        let framesPerSecond = format.sampleRate
        let slots = max(2, Int((Self.replaySeconds * framesPerSecond / Double(bufferFrames)).rounded(.up)))
        // Тап не гарантирует ровно `bufferFrames` в буфере, поэтому берём запас.
        let capacity = bufferFrames * 2
        let buffers = (0 ..< slots).compactMap {
            _ in AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity)
        }

        lock.lock()
        defer { lock.unlock() }

        request = nil
        ring = buffers
        ringWriteIndex = 0
        ringFilled = 0
    }

    /// Вызывается с аудиопотока.
    func append(
        _ buffer: AVAudioPCMBuffer
    ) {
        lock.lock()
        defer { lock.unlock() }

        request?.append(buffer)
        remember(buffer)
    }

    /// Подключает новую задачу и переливает в неё накопленный хвост, чтобы
    /// слова на стыке задач не пропадали.
    func attach(
        _ newRequest: SFSpeechAudioBufferRecognitionRequest
    ) {
        lock.lock()
        defer { lock.unlock() }

        request = newRequest
        for buffer in orderedRingBuffers() {
            newRequest.append(buffer)
        }
    }

    /// Отсоединяет запрос: буферы с микрофона перестают в него попадать.
    func detach() {
        lock.lock()
        defer { lock.unlock() }

        request = nil
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }

        request = nil
        ring = []
        ringWriteIndex = 0
        ringFilled = 0
    }

    /// Копирует буфер в кольцо: тот, что пришёл в тап, движок переиспользует
    /// сразу после возврата из колбэка, и сохранять саму ссылку нельзя.
    private func remember(
        _ buffer: AVAudioPCMBuffer
    ) {
        guard !ring.isEmpty else { return }
        guard let source = buffer.floatChannelData else { return }

        let slot = ring[ringWriteIndex]
        guard let destination = slot.floatChannelData else { return }
        guard buffer.format.channelCount == slot.format.channelCount else { return }

        let frames = min(buffer.frameLength, slot.frameCapacity)
        let bytes = Int(frames) * MemoryLayout<Float>.size
        for channel in 0 ..< Int(slot.format.channelCount) {
            memcpy(destination[channel], source[channel], bytes)
        }
        slot.frameLength = frames

        ringWriteIndex = (ringWriteIndex + 1) % ring.count
        ringFilled = min(ringFilled + 1, ring.count)
    }

    /// Буферы кольца в хронологическом порядке — от самого старого к свежему.
    private func orderedRingBuffers() -> [AVAudioPCMBuffer] {
        guard ringFilled > 0 else { return [] }

        let start = (ringWriteIndex - ringFilled + ring.count) % ring.count

        return (0 ..< ringFilled).map { ring[(start + $0) % ring.count] }
    }
}
