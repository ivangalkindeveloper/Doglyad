import Foundation
import Metal
import os

enum DNeuralDevice {
    static func canRunLocally(model: DNeuralModelData, maxTokens: Int) -> Bool {
        guard deviceSupportsRequiredGPUFamily() else { return false }

        let avail: UInt64
        if #available(iOS 16.0, *) {
            avail = availableMemoryBytes()
        } else {
            avail = legacyAvailableMemoryBytes()
        }
        guard avail > 0 else { return false }

        let need = estimateFootprintBytes(model: model, maxTokens: maxTokens)
        // Требуем, чтобы хватало хотя бы с 50% запасом
        return need < avail / 2
    }

    @available(iOS 16.0, *)
    private static func availableMemoryBytes() -> UInt64 {
        UInt64(os_proc_available_memory())
    }

    private static func legacyAvailableMemoryBytes() -> UInt64 {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let HOST_VM_INFO64_COUNT: mach_msg_type_number_t = numericCast(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(HOST_VM_INFO64_COUNT)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        let freeBytes = UInt64(stats.free_count) * UInt64(vm_kernel_page_size)
        let inactiveBytes = UInt64(stats.inactive_count) * UInt64(vm_kernel_page_size)
        return freeBytes + inactiveBytes
    }

    private static func deviceSupportsRequiredGPUFamily() -> Bool {
        guard let device = MTLCreateSystemDefaultDevice() else { return false }
        if #available(iOS 16.0, *) {
            // MLX на iOS практически требует не ниже Apple 7 (A14+)
            return device.supportsFamily(.apple7)
        } else {
            // Для старых iOS просто факт наличия Metal
            return true
        }
    }

    private static func estimateFootprintBytes(model: DNeuralModelData, maxTokens: Int) -> UInt64 {
        // Веса: params * (quantBits/8)
        let weightBytes = UInt64(model.params) * UInt64(model.quantBits) / 8
        // KV-cache: 2 (K/V) * numLayers * hiddenSize * bytesPerVal (fp16=2) * maxTokens
        let kvPerToken = 2 * model.numLayers * model.hiddenSize * 2
        let kvBytes = UInt64(maxTokens) * UInt64(kvPerToken)
        // Небольшой запас под планировщик/промежуточные буферы
        let overhead: UInt64 = 200 * 1024 * 1024
        return weightBytes + kvBytes + overhead
    }
}
