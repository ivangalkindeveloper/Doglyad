//
//  MicrophonePermissionBottomSheet.swift
//  Doglyad
//
//  Created by Иван Галкин on 25.01.2026.
//

import SwiftUI

struct PermissionSpeechBottomSheet: View {
    var body: some View {
        PermissionBottomSheet(
            title: .permissionSpeechTitle,
            description: .permissionSpeechDescription,
        )
    }
}
