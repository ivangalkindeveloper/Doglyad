import DoglyadUI
import SwiftUI

struct ServiceUnavailableScreenView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: ServiceUnavailableViewModel

    var body: some View {
        DScreen { _, _ in
            VStack(
                alignment: .center,
                spacing: .zero
            ) {
                Spacer()

                Image(.onBoarding4)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .padding(size.s16)

                DText(.serviceUnavailableTitle)
                    .dStyle(
                        font: theme.typography.linkMedium,
                        alignment: .center
                    )
                    .padding(.bottom, size.s16)

                DText(.serviceUnavailableDescription)
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscalePlacehold,
                        alignment: .center
                    )

                Spacer()
            }
            .padding(size.s16)
        }
    }
}
