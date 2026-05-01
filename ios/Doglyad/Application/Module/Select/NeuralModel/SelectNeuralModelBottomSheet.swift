import DoglyadUI
import Router
import SwiftUI

struct SelectNeuralModelBottomSheet: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: SelectNeuralModelArguments?

    var body: some View {
        DBottomSheet(
            title: .neuralModelTitle,
            fraction: 0.8
        ) { toolbarHeight in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: .zero
                ) {
                    ForEach(container.usExaminationNeuralModels) { model in
                        DListButtonCard(
                            title: LocalizedStringResource(stringLiteral: model.title),
                            description: """
                            (\(model.id))
                            \(model.getLocalizedDescription(for: Locale.current))
                            """,
                            action: {
                                router.dismissSheet()
                                arguments?.onSelected(model)
                            },
                            isSelected: arguments?.currentValue == model
                        )
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

#Preview {
    SelectNeuralModelBottomSheet(
        arguments: nil
    )
    .previewable()
}
