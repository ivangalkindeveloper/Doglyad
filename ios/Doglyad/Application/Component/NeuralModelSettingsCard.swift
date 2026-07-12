import DoglyadUI
import SwiftUI

struct NeuralModelSettingsCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel

    let onTap: () -> Void
    var badgeTitle: LocalizedStringResource = .entitlementPro
    var isBadgeVisible: Bool = false
    var isBadgeShimmering: Bool = false

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

            DBadge(
                badgeTitle,
                isVisible: isBadgeVisible,
                isShimmering: isBadgeShimmering
            ) {
                DButtonCard(
                    action: onTap
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: size.s4
                    ) {
                        NeuralModelSettingsMarkdownRow(
                            isMarkdown: $ultrasoundViewModel.isMarkdown
                        )

                        NeuralModelValueRow(
                            title: .scanNeuralModelSettingsTemperatureLabel,
                            value: String(format: "%.2f", ultrasoundViewModel.temperature)
                        )

                        NeuralModelValueRow(
                            title: .scanNeuralModelSettingsMaxTokensLabel,
                            value: "\(ultrasoundViewModel.maxTokens)"
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct NeuralModelSettingsMarkdownRow: View {
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
