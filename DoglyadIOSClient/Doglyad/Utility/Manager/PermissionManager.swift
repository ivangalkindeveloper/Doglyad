//
//  PermissionManager.swift
//  Doglyad
//
//  Created by Иван Галкин on 18.10.2025.
//

import AVFoundation

enum PermissionType {
    case camera
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
        switch(type) {
        case .camera:
            await AVCaptureDevice.requestAccess(for: .video)
        }
    }
}
