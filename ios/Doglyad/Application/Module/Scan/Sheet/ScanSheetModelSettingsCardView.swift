import DoglyadUI
import SwiftUI

struct ScanSheetModelSettingsCardView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: ScanViewModel
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            DText(.scanNeuralModelSettingsTitleLabel)
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlacehold
                )
                .padding(.horizontal, size.s8)
                .padding(.bottom, size.s8)

            DButtonCard(
                action: viewModel.onTapNeuralModelSettings
            ) {
                VStack(
                    alignment: .leading,
                    spacing: size.s4
                ) {
                    row(
                        title: .scanNerualModelSettingsModelLabel,
                        value: ultrasoundViewModel.neuralModel.title
                    )

                    row(
                        title: .scanNeuralModelSettingsTemperatureLabel,
                        value: String(format: "%.2f", ultrasoundViewModel.temperature)
                    )

                    row(
                        title: .scanNeuralModelSettingsResponseLengthLabel,
                        value: "\(ultrasoundViewModel.responseLength)"
                    )

                    row(
                        title: .scanNeuralModelSettingsAvailableRequestsLabel,
                        value: "\(ultrasoundViewModel.availableRequestCount)"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func row(
        title: LocalizedStringResource,
        value: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: size.s4
        ) {
            DText(title)
                .dStyle(
                    font: typography.textXSmall,
                    color: color.grayscalePlacehold
                )

            DText(value)
                .dStyle(
                    font: typography.linkSmall
                )
                .lineLimit(2)
        }
    }
}
