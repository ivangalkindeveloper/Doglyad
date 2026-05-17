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
                    RowView(
                        title: .scanNerualModelSettingsModelLabel,
                        value: ultrasoundViewModel.neuralModel.title
                    )

                    MarkdownRowView(
                        isMarkdown: $ultrasoundViewModel.isMarkdown
                    )

                    RowView(
                        title: .scanNeuralModelSettingsTemperatureLabel,
                        value: String(format: "%.2f", ultrasoundViewModel.temperature)
                    )

                    RowView(
                        title: .scanNeuralModelSettingsMaxTokensLabel,
                        value: "\(ultrasoundViewModel.maxTokens)"
                    )

                    RowView(
                        title: .scanNeuralModelSettingsAvailableRequestsLabel,
                        value: "\(ultrasoundViewModel.availableRequestCount)"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct RowView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let title: LocalizedStringResource
    let value: String

    var body: some View {
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

private struct MarkdownRowView: View {
    private static let switchNativeHeight: CGFloat = 31
    private static let switchNativeWidth: CGFloat = 51

    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @Binding var isMarkdown: Bool

    private var switchScale: CGFloat {
        size.s12 / Self.switchNativeHeight
    }

    var body: some View {
        HStack(
            alignment: .center,
            spacing: size.s8
        ) {
            DText(.scanNeuralModelSettingsMarkdownLabel)
                .dStyle(
                    font: typography.textXSmall,
                    color: color.grayscalePlacehold
                )

            Toggle(
                "",
                isOn: $isMarkdown
            )
            .labelsHidden()
            .toggleStyle(.switch)
            .scaleEffect(switchScale)
            .frame(
                width: Self.switchNativeWidth * switchScale,
                height: size.s12
            )
            .allowsHitTesting(false)
        }
    }
}
