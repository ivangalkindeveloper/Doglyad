import DoglyadUI
import Foundation
import SwiftUI

struct PermissionBottomSheet: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    var body: some View {
        DBottomSheet(
            title: title
        ) {
            VStack(
                spacing: .zero,
            ) {
                DText(description)
                    .dStyle(
                        font: typography.textSmall,
                        alignment: .center
                    )
                    .padding(.bottom, size.s32)
                DButton(
                    title: .buttonOpenSettings,
                    action: UIApplication.openSettings,
                )
                .dStyle(.primaryButton)
            }
            .padding(size.s16)
        }
    }
}
