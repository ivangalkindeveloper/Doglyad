import DoglyadUI
import Router
import SwiftUI

struct ScanRequestLimitExceededBottomSheet: View {
    @EnvironmentObject private var router: DRouter
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: ScanRequestLimitExceededArguments?

    var body: some View {
        DBottomSheet(
            title: .scanLimitExceededTitle,
            isCloseButtonVisible: false,
            fraction: 0.3
        ) { toolbarHeight in
            VStack(
                spacing: .zero
            ) {
                DText(.scanLimitExceededDescription)
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
                title: .buttonBack
            ) {
                router.dismissSheet()
            }
            .dStyle(.primaryButton)
            .padding(.horizontal, size.s16)
        }
    }
}

#Preview {
    ScanRequestLimitExceededBottomSheet(
        arguments: nil
    )
    .previewable()
}
