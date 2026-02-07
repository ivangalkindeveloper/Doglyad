import DoglyadUI
import SwiftUI

struct HistoryEmptyView: View {
    @EnvironmentObject var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: HistoryViewModel

    var body: some View {
        VStack(
            spacing: .zero
        ) {
            DText(.historyEmptyDescription)
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlaceholder,
                    alignment: .center
                ).padding(.bottom, size.s16)
            DButton(
                title: .buttonBack,
                action: viewModel.onTapBack
            )
            .dStyle(.primaryButton)
        }
        .padding(.top, size.screenHeight / 4)
    }
}
