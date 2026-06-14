import DoglyadUI
import SwiftUI

struct SettingsScreenView: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }

    @StateObject var viewModel: SettingsViewModel

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
                            title: .settingsUserSettingsTitle,
                            description: .settingsUserSettingsDescription,
                            action: viewModel.onTapUserSettings
                        )
                        DListButtonCard(
                            title: .settingsSubscriptionManageTitle,
                            description: .settingsSubscriptionManageDescription,
                            action: viewModel.onTapSubscription
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
                    .padding(.bottom, size.s32)

                    DButton(
                        image: .link,
                        title: .settingsAboutAppTitle,
                        action: viewModel.onTapAboutApp
                    )
                    .dStyle(.primaryText)
                    .padding(.bottom, size.s32)
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .environmentObject(viewModel)
    }
}
