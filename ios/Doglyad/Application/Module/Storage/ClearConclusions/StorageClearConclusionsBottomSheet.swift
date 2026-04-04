import DoglyadUI
import Router
import SwiftUI

struct StorageClearConclusionsBottomSheet: View {
    @EnvironmentObject private var router: DRouter
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: StorageClearConclusionsArguments?

    var body: some View {
        DBottomSheet(
            title: .storageClearConclusionsWarningTitle,
            fraction: 0.3
        ) { toolbarHeight in
            VStack(
                spacing: .zero
            ) {
                DText(.storageClearConclusionsWarningDescription)
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscalePlacehold,
                        alignment: .center
                    )
                    .padding(.top, toolbarHeight + size.s24)
                    .padding(.horizontal, size.s16)
                Spacer()
            }
        } bottom: {
            DButton(
                title: .buttonClear
            ) {
                router.dismissSheet()
                arguments?.onConfirm()
            }
            .dStyle(.primaryButton)
            .padding(.horizontal, size.s16)
        }
    }
}

#Preview {
    StorageClearConclusionsBottomSheet(
        arguments: nil
    )
    .previewable()
}
