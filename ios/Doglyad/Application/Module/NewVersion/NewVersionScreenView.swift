import DoglyadUI
import SwiftUI

struct NewVersionScreenView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: NewVersionViewModel

    var body: some View {
        DScreen(
            title: .newVersionTitle,
            onTapBack: nil
        ) { toolbarInset in
            VStack(
                spacing: .zero
            ) {
                Spacer()

                VStack(
                    spacing: size.s16
                ) {
                    ZStack {
                        Circle()
                            .fill(color.gradientPrimaryWeak)
                        DIcon(
                            .alertInfo,
                            color: color.grayscaleBackground
                        )
                    }
                    .frame(width: size.s64, height: size.s64)

                    DText(.newVersionDescription0)
                        .dStyle(
                            font: typography.linkSmall,
                            alignment: .center
                        )

                    DText(.newVersionDescription1)
                        .dStyle(
                            font: typography.textSmall,
                            color: color.grayscalePlacehold,
                            alignment: .center
                        )
                }
                .padding(.bottom, size.s14)

                Spacer()

                DButton(
                    title: .buttonUpdate,
                    action: viewModel.onTapUpdate
                )
                .dStyle(.primaryButton)
            }
            .padding(size.s16)
            .padding(.top, toolbarInset)
        }
    }
}
