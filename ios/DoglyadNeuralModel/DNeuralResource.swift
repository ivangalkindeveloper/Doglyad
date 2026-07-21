import Foundation

enum DNeuralResource {
    static func directorySize(
        at directory: URL
    ) -> UInt64 {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]
        ) else {
            return 0
        }

        var total: UInt64 = 0
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(
                forKeys: [.fileSizeKey, .isRegularFileKey]
            ) else {
                continue
            }
            guard values.isRegularFile == true else { continue }

            total += UInt64(values.fileSize ?? 0)
        }

        return total
    }
}
