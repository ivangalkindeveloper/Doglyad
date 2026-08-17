import DoglyadUI
import SwiftUI

struct NeuralModelConclusionCard: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let conclusion: USExaminationModelConclusion
    let onTapCopy: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            HStack(
                alignment: .top,
                spacing: .zero
            ) {
                VStack(
                    alignment: .leading,
                    spacing: .zero
                ) {
                    HStack(
                        alignment: .bottom,
                        spacing: .zero
                    ) {
                        DText(.conclusionResponseModelLabel)
                            .dStyle(
                                font: typography.textSmall
                            )
                            .padding(.trailing, size.s4)
                        if let modelTitle = container.getUSExaminationNeuralModelById(id: conclusion.modelId)?.title {
                            DText(modelTitle)
                                .dStyle(
                                    font: typography.linkSmall
                                )
                        }
                    }

                    HStack(
                        alignment: .bottom,
                        spacing: .zero
                    ) {
                        DText(.conclusionResponseDateLabel)
                            .dStyle(
                                font: typography.textSmall
                            )
                            .padding(.trailing, size.s4)

                        DText(conclusion.date.localized())
                            .dStyle(
                                font: typography.linkSmall
                            )
                    }
                }

                Spacer()

                Button(
                    action: onTapCopy
                ) {
                    DIcon(
                        .copy,
                        color: color.primaryDefault,
                        height: size.s20
                    )
                }
                .buttonStyle(.plain)
                .padding(.leading, size.s8)
            }
            .padding(.bottom, size.s8)

            ExpandableMarkdown(
                text: conclusion.response,
                backgroundColor: color.grayscaleBackground,
                collapsedLineLimit: 12
            )
        }
        .padding(size.s16)
        .background(color.grayscaleBackground)
        .cornerRadius(size.s16)
    }
}

#Preview {
    NeuralModelConclusionCard(
        conclusion: USExaminationModelConclusion(
            date: Date(),
            modelId: "google/medgemma-1.5-4b-it",
            response: """
            The thyroid is in its normal position and its structure is preserved.
            Both lobes are within the normal size range for age, with no abnormalities.
            Parenchymal echogenicity is uniform, without pathological decreases or increases.
            No focal lesions, nodules, cysts, or calcifications were detected.
            The gland contours are smooth and well defined; the capsule is not thickened.
            Color Doppler shows no increased blood flow; values are physiological.
            Regional lymph nodes show no enlargement or structural changes.
            No signs of inflammation or autoimmune involvement were observed.
            The findings correspond to a normal thyroid ultrasound appearance.
            Routine follow-up ultrasound is recommended when clinically indicated.
            """
        ),
        onTapCopy: {}
    )
    .padding()
    .dThemeWrapper()
}
