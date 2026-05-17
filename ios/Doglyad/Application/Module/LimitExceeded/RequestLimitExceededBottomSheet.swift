import DoglyadUI
import Router
import SwiftUI

struct RequestLimitExceededBottomSheet: View {
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: RequestLimitExceededArguments?

    var body: some View {
        DBottomSheet(
            title: .requestLimitExceededTitle,
            isCloseButtonVisible: false,
            fraction: 0.3
        ) { toolbarHeight in
            VStack(
                spacing: .zero
            ) {
                DText(.requestLimitExceededDescription)
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
    RequestLimitExceededBottomSheet(
        arguments: nil
    )
    .previewable()
}
