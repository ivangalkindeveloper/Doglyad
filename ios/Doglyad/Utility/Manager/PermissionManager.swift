import AVFoundation
import Speech

enum PermissionType {
    case camera
    case speech
}

protocol PermissionManagerProtocol: AnyObject {
    func isGranted(
        _ type: PermissionType
    ) async -> Bool
}

final class PermissionManager {}

extension PermissionManager: PermissionManagerProtocol {
    func isGranted(
        _ type: PermissionType
    ) async -> Bool {
        switch type {
        case .camera:
            await AVCaptureDevice.requestAccess(for: .video)

        case .speech:
            await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        continuation.resume(returning: true)
                    default:
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
}
