import DoglyadUI
import Foundation
import SwiftUI

struct SelectNeuralModelBottomSheetView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: SelectNeuralModelViewModel

    var body: some View {
        DBottomSheet(
            title: .settingsNeuralModelTitle,
            fraction: 0.8
        ) { toolbarHeight, _ in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: .zero
                ) {
                    ForEach(viewModel.models) { model in
                        DBadge(
                            .entitlementPro,
                            isVisible: viewModel.isProBadgeVisible(for: model),
                            isShimmering: true
                        ) {
                            DListButtonCard(
                                title: LocalizedStringResource(stringLiteral: model.title),
                                description: """
                                \(String(localized: .neuralModelContextLengthDescription)) \(model.contextLength)
                                (\(model.id))
                                \(model.getLocalizedDescription(for: Locale.current))
                                """,
                                action: {
                                    viewModel.onModelTap(model)
                                },
                                isSelected: viewModel.isSelected(model)
                            )
                        }
                    }
                    .padding(.bottom, size.s8)
                }
                .padding(size.s16)
                .padding(.top, toolbarHeight)
                .padding(.bottom, size.s116)
            }
        }
        bottom: {
            DText(
                .neuralModelAddingDescription
            )
            .dStyle(
                font: typography.textSmall,
                color: color.grayscalePlacehold,
                alignment: .center
            )
            .padding(.top, size.s16)
            .padding(.horizontal, size.s16)
        }
    }
}
