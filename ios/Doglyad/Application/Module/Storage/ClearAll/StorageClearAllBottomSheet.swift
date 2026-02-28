import DoglyadUI
import Router
import SwiftUI

struct StorageClearAllBottomSheet: View {
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: StorageClearAllArguments?

    var body: some View {
        DBottomSheet(
            title: .storageClearAllWarningTitle,
            fraction: 0.3
        ) {
            VStack(
                spacing: .zero
            ) {
                DText(.storageClearAllWarningDescription)
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscalePlacehold,
                        alignment: .center
                    )
                    .padding(.top, size.s24)
                    .padding(.horizontal, size.s16)
                Spacer()
            }
        } bottom: {
            DButton(
                title: .buttonClearAll
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
    StorageClearAllBottomSheet(
        arguments: nil
    )
    .previewable()
}
