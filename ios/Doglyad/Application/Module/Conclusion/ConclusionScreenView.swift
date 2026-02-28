import DoglyadUI
import SwiftUI

struct ConclusionScreenView: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: ConclusionViewModel
    private var conclusion: USExaminationConclusion {
        viewModel.conclusion
    }
    private var examinationData: USExaminationData {
        viewModel.conclusion.examinationData
    }

    var body: some View {
        DScreen(
            title: .conclusionTitle,
            subTitle: "\(examinationData.patientName), \(conclusion.date.localized())",
            onTapBack: viewModel.onTapBack,
            trailing: {
                ShareLink(
                    item: viewModel.conclusionShareContent
                ) {
                    DButton(
                        image: .export,
                        action: {}
                    )
                    .dStyle(.circle)
                    .allowsHitTesting(false)
                }
            }
        ) { toolbarInset in
            ScrollViewReader { proxy in
                ScrollView(
                    showsIndicators: false
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: .zero
                    ) {
                        DText(
                            LocalizedStringResource.forExaminationTypeById(
                                types: container.usExaminationTypesById,
                                id: examinationData.usExaminationTypeId,
                                locale: Locale.current
                            )
                        )
                            .dStyle(
                                font: typography.linkLarge
                            )
                            .padding(.horizontal, size.s16)
                            .padding(.bottom, size.s16)

                        ConclusionPhotosView()

                        VStack(
                            alignment: .leading,
                            spacing: .zero
                        ) {
                            DText(.scanExaminationDateLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )

                            DText(conclusion.date.localized())
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientNameLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )

                            DText(examinationData.patientName)
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientGenderLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )

                            DText(.forGender(examinationData.patientGender))
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientDateOfBirthLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )

                            DText(examinationData.patientDateOfBirth.localized())
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanExaminationDescriptionLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )

                            ExpandableText(
                                text: examinationData.examinationDescription,
                                backgroundColor: color.grayscaleBackground
                            )
                            .padding(.bottom, size.s8)

                            if let patientComplaint = examinationData.patientComplaint {
                                DText(.scanPatientComplaintLabel)
                                    .dStyle(
                                        font: typography.linkSmall,
                                        color: color.grayscalePlacehold
                                    )

                                ExpandableText(
                                    text: patientComplaint,
                                    backgroundColor: color.grayscaleBackground
                                )
                                .padding(.bottom, size.s8)
                            }

                            if let additionalData = examinationData.additionalData {
                                DText(.scanAdditionalDataLabel)
                                    .dStyle(
                                        font: typography.linkSmall,
                                        color: color.grayscalePlacehold
                                    )

                                ExpandableText(
                                    text: additionalData,
                                    backgroundColor: color.grayscaleBackground
                                )
                                .padding(.bottom, size.s8)
                            }

                            DText(.conclusionActualModelResponseTitle)
                                .dStyle(
                                    font: typography.linkLarge
                                )
                                .padding(.top, size.s16)
                                .padding(.horizontal, size.s8)
                                .padding(.bottom, size.s16)

                            ModelConclusionCard(
                                conclusion: conclusion.actualModelConclusion,
                                onTapCopy: { viewModel.onTapCopy(conclusion: conclusion.actualModelConclusion) }
                            )
                            .id(ConclusionViewModel.actualModelConclusionCardScrollId)
                            .padding(.bottom, size.s16)

                            DButton(
                                image: .refresh,
                                title: .buttonRepeatScan,
                                action: {
                                    viewModel.onTapRepeatScan(
                                        proxy: proxy
                                    )
                                },
                                isLoading: viewModel.isLoading
                            )
                            .dStyle(.primaryButton)
                            .padding(.bottom, size.s16)

                            if !conclusion.previosModelConclusions.isEmpty {
                                DText(.conclusionPreviosModelResponsesTitle)
                                    .dStyle(
                                        font: typography.linkLarge
                                    )
                                    .padding(.top, size.s8)
                                    .padding(.horizontal, size.s8)
                                    .padding(.bottom, size.s16)

                                ForEach(conclusion.previosModelConclusions) { modelConclusion in
                                    ModelConclusionCard(
                                        conclusion: modelConclusion,
                                        onTapCopy: { viewModel.onTapCopy(conclusion: modelConclusion) }
                                    )
                                    .padding(.bottom, size.s8)
                                }
                            }
                        }
                        .padding(.horizontal, size.s16)
                    }
                    .padding(.top, size.s16 + toolbarInset)
                    .padding(.bottom, size.s128)
                }
            }
        }
        .environmentObject(viewModel)
    }
}
