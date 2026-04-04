import DoglyadUI
import SwiftUI

struct StorageScreenView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: StorageViewModel

    var body: some View {
        DScreen(
            title: .storageTitle,
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: size.s8
                ) {
                    DListButtonCard(
                        title: .storageClearConclusionsTitle,
                        description: .storageClearConclusionsDescription,
                        action: viewModel.onTapClearConclusions
                    )
                    DListButtonCard(
                        title: .storageClearAllTitle,
                        description: .storageClearAllDescription,
                        action: viewModel.onTapClearAll
                    )
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
        }
        .environment(viewModel)
    }
}
