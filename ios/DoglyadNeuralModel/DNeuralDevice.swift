import Foundation
import Metal
import os

enum DNeuralDevice {
    /// The model stays in memory for the whole app session and coexists with the
    /// camera session, so headroom is needed. But too strict a threshold simply
    /// disables the feature on 4 GB devices, so we settle on a moderate 30%.
    private static let memoryHeadroomFactor: Double = 0.7
    /// Headroom for the scheduler and intermediate buffers.
    private static let overheadBytes: UInt64 = 200 * 1024 * 1024
    /// The KV cache is stored in fp16.
    private static let cacheValueBytes: UInt64 = 2

    /// MLX on iOS effectively requires Apple 7 (A14+) or newer.
    /// Creating an MTLDevice is not free, so the result is computed once.
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

    /// K and V per layer, numKeyValueHeads heads of headDimension each.
    private static func kvCacheBytes(
        model: DNeuralModelData,
        maxContextTokens: Int
    ) -> UInt64 {
        let perToken = UInt64(2 * model.numLayers * model.numKeyValueHeads * model.headDimension) * cacheValueBytes

        return perToken * UInt64(maxContextTokens)
    }
}
