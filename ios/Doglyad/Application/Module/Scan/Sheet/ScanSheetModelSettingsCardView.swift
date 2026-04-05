import DoglyadUI
import SwiftUI

struct ScanSheetModelSettingsCardView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @Environment(ScanViewModel.self) private var viewModel

    var body: some View {
        let settings = viewModel.neuralModelSettings
        
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
                if let modelId = settings.selectedNeuralModelId,
                   let model = container.usExaminationNeuralModelsById[modelId]
                {
                    row(
                        title: .scanNerualModelSettingsModelLabel,
                        value: model.title
                    )
                }

                if let template = settings.template, !template.isEmpty {
                    row(
                        title: .scanNeuralModelSettingsTemplateLabel,
                        value: template
                    )
                }

                if let responseLength = settings.responseLength {
                    row(
                        title: .scanNeuralModelSettingsResponseLengthLabel,
                        value: "\(responseLength)"
                    )
                }

                row(
                    title: .scanNeuralModelSettingsAvailableRequestsLabel,
                    value: "\(viewModel.availableRequestCount)"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    font: typography.textXSmall
                )
                .lineLimit(2)
        }
    }
}
