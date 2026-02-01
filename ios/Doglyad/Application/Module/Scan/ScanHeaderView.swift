import DoglyadUI
import SwiftUI

struct ScanHeaderView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        HStack(
            spacing: .zero
        ) {
            DButton(
                image: .hambergerMenu,
                action: viewModel.onTapHistory
            )
            .dStyle(.circle)

            Spacer()

            DButton(
                title: .forResearchType(viewModel.researchType),
                action: viewModel.onTapResearchType
            )
            .dStyle(.primaryChip)
            .padding([.trailing, .leading], size.s16)

            Spacer()

            Color.clear
                .frame(
                    width: size.s56
                )
        }
        .frame(
            height: size.s56
        )
    }
}
