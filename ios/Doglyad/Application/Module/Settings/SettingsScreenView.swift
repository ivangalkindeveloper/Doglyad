import DoglyadUI
import SwiftUI

struct SettingsScreenView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: SettingsViewModel

    var body: some View {
        DScreen(
            title: .settingsTitle,
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: .zero
                ) {
                    VStack(
                        spacing: size.s8
                    ) {
                        DListButtonCard(
                            title: .settingsHistoryTitle,
                            description: viewModel.historyDescription(),
                            action: viewModel.onTapHistory
                        )
                        DListButtonCard(
                            title: .settingsTemplatesTitle,
                            description: .settingsTemplatesDescription,
                            action: viewModel.onTapTemplates
                        )
                        DListButtonCard(
                            title: .settingsNeuralModelTitle,
                            description: .settingsNeuralModelDescription,
                            action: viewModel.onTapNeuralModel
                        )
                        DListButtonCard(
                            title: .settingsStorageTitle,
                            description: .settingsStorageDescription,
                            action: viewModel.onTapStorage
                        )
                        DListButtonCard(
                            title: .settingsPrivacyPolicyTitle,
                            description: .settingsPrivacyPolicyDescription,
                            action: viewModel.onTapPrivacyPolicy
                        )
                        DListButtonCard(
                            title: .settingsTermsAndConditionsTitle,
                            description: .settingsTermsAndConditionsDescription,
                            action: viewModel.onTapTermsAndConditions
                        )
                    }
                    .padding(.bottom, size.s48)

                    Button(
                        action: viewModel.onTapAboutApp
                    ) {
                        HStack(
                            spacing: size.s8
                        ) {
                            DIcon(
                                .link,
                                color: color.primaryDefault
                            )
                            DText(.settingsAboutAppTitle)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.primaryDefault,
                                    alignment: .center
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
        }
        .onAppear {
            viewModel.onInit()
        }
        .environment(viewModel)
    }
}
