import Accelerate
import AVFAudio
import Foundation

/// Считает уровень микрофона для индикатора на экране диктовки.
///
/// Живёт на аудиопотоке, поэтому RMS берём через `vDSP` прямо по указателю
/// буфера — без копии в `Array` и промежуточных `map`/`reduce`: аллокации в
/// колбэке тапа приводят к пропускам звука, а значит и к потерянным словам.
///
/// Публикуем не каждый буфер (их около полусотни в секунду), а по таймеру:
/// индикатору хватает ~20 кадров, а каждое обновление `@Published` тянет за
/// собой перерисовку всего экрана диктовки.
final class DSpeechAudioMeter: @unchecked Sendable {
    /// Шаг публикации уровня — 20 кадров в секунду.
    private static let publishInterval: TimeInterval = 0.05
    /// Доля нового значения в сглаживании. Без него индикатор дёргается на
    /// каждом слоге, с ним — плавно следует за громкостью.
    private static let smoothing: Float = 0.4
    /// Подъём RMS до диапазона индикатора: речь с руки редко даёт больше 0.07.
    private static let gain: Float = 15

    private let lock = NSLock()
    private var level: Float = 0
    private var lastPublishUptime: TimeInterval = 0
    private let onLevel: @Sendable (Float) -> Void

    init(
        onLevel: @escaping @Sendable (Float) -> Void
    ) {
        self.onLevel = onLevel
    }

    /// Вызывается с аудиопотока.
    func process(
        _ buffer: AVAudioPCMBuffer
    ) {
        guard buffer.frameLength > 0 else { return }
        guard let channel = buffer.floatChannelData?[0] else { return }

        var rms: Float = 0
        vDSP_rmsqv(channel, 1, &rms, vDSP_Length(buffer.frameLength))
        let target = min(max(rms * Self.gain, 0), 1)
        let now = ProcessInfo.processInfo.systemUptime

        lock.lock()
        level += (target - level) * Self.smoothing
        guard now - lastPublishUptime >= Self.publishInterval else {
            lock.unlock()
            return
        }
        lastPublishUptime = now
        let published = level
        lock.unlock()

        onLevel(published)
    }

    func reset() {
        lock.lock()
        level = 0
        lastPublishUptime = 0
        lock.unlock()

        onLevel(0)
    }
}
