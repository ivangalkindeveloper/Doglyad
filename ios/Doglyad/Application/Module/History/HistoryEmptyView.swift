import SwiftUI
import DoglyadUI

struct HistoryEmptyView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }
    
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
        .padding(.top, size.s128)
    }
}
