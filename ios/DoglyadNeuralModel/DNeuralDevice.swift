import Foundation
import Metal
import os

enum DNeuralDevice {
    /// Модель остаётся в памяти всё время работы приложения и соседствует
    /// с сессией камеры, поэтому запас нужен. Но слишком строгий порог просто
    /// отключает фичу на устройствах с 4 ГБ, поэтому берём умеренные 30%.
    private static let memoryHeadroomFactor: Double = 0.7
    /// Запас под планировщик и промежуточные буферы.
    private static let overheadBytes: UInt64 = 200 * 1024 * 1024
    /// KV-кэш хранится в fp16.
    private static let cacheValueBytes: UInt64 = 2

    /// MLX на iOS практически требует не ниже Apple 7 (A14+).
    /// Создание MTLDevice не бесплатно, поэтому результат считаем один раз.
    private static let isGPUSupported: Bool = {
        guard let device = MTLCreateSystemDefaultDevice() else { return false }

        return device.supportsFamily(.apple7)
    }()

    static func canRunLocally(
        model: DNeuralModelData,
        weightsBytes: UInt64,
        maxContextTokens: Int
    ) -> Bool {
        guard isGPUSupported else { return false }
        guard weightsBytes > 0 else { return false }

        let available = UInt64(os_proc_available_memory())
        guard available > 0 else { return false }

        let needed = weightsBytes + kvCacheBytes(
            model: model,
            maxContextTokens: maxContextTokens
        ) + overheadBytes

        return Double(needed) < Double(available) * memoryHeadroomFactor
    }

    /// K и V на каждый слой, по numKeyValueHeads голов размером headDimension.
    private static func kvCacheBytes(
        model: DNeuralModelData,
        maxContextTokens: Int
    ) -> UInt64 {
        let perToken = UInt64(2 * model.numLayers * model.numKeyValueHeads * model.headDimension) * cacheValueBytes

        return perToken * UInt64(maxContextTokens)
    }
}
