import DoglyadUI
import SwiftUI

struct ConclusionScreenView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: ConclusionViewModel
    var conclusion: ResearchConclusion {
        viewModel.conclusion
    }

    var body: some View {
        DScreen(
            title: .conclusionTitle,
            subTitle: "\(conclusion.researchData.patientName), \(conclusion.date.localized())",
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollViewReader { proxy in
                ScrollView(
                    showsIndicators: false
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: .zero
                    ) {
                        DText(.forResearchType(conclusion.researchData.researchType))
                            .dStyle(
                                font: typography.linkLarge
                            )
                            .padding(size.s16)
                            .padding(.horizontal, size.s8)

                        ConclusionPhotosView()

                        VStack(
                            alignment: .leading,
                            spacing: .zero
                        ) {
                            DText(.scanResearchDateLabel)
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
                            
                            DText(conclusion.researchData.patientName)
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientGenderLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )
                            
                            DText(.forGender(conclusion.researchData.patientGender))
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientDateOfBirthLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )
                            
                            DText(conclusion.researchData.patientDateOfBirth.localized())
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanResearchDescriptionLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlacehold
                                )
                            
                            ExpandableText(
                                text: conclusion.researchData.researchDescription,
                                backgroundColor: color.grayscaleBackgroundWeak
                            )
                            .padding(.bottom, size.s8)

                            if let patientComplaint = conclusion.researchData.patientComplaint {
                                DText(.scanPatientComplaintLabel)
                                    .dStyle(
                                        font: typography.linkSmall,
                                        color: color.grayscalePlacehold
                                    )
                                
                                ExpandableText(
                                    text: patientComplaint,
                                    backgroundColor: color.grayscaleBackgroundWeak
                                )
                                .padding(.bottom, size.s8)
                            }

                            if let additionalData = conclusion.researchData.additionalData {
                                DText(.scanAdditionalDataLabel)
                                    .dStyle(
                                        font: typography.linkSmall,
                                        color: color.grayscalePlacehold
                                    )
                                
                                ExpandableText(
                                    text: additionalData,
                                    backgroundColor: color.grayscaleBackgroundWeak
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
                                conclusion: conclusion.actualModelConclusion
                            )
                            .padding(.bottom, size.s16)

                            DButton(
                                image: .refresh,
                                title: .buttonRepeatScan,
                                action: {
                                    viewModel.onTapRepeatScan(proxy: proxy)
                                }
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
                                        conclusion: modelConclusion
                                    )
                                    .padding(.bottom, size.s8)
                                }
                            }
                        }
                        .padding(.top, size.s16 + toolbarInset)
                        .padding(.horizontal, size.s16)
                        .padding(.bottom, size.s128)
                    }
                }
            }
        }
        .environmentObject(viewModel)
    }
}
