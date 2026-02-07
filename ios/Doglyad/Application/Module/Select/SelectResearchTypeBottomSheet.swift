import DoglyadUI
import Router
import SwiftUI

final class SelectResearchTypeArguments: RouteArgumentsProtocol {
    let currentValue: ResearchType?
    let onSelected: (ResearchType) -> Void

    init(
        currentValue: ResearchType? = nil,
        onSelected: @escaping (ResearchType) -> Void
    ) {
        self.currentValue = currentValue
        self.onSelected = onSelected
    }
}

struct SelectResearchTypeBottomSheet: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: SelectResearchTypeArguments?

    var body: some View {
        DBottomSheet(
            title: .researchTypeTitle,
            fraction: 0.8
        ) {
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: .zero
                ) {
                    ForEach(container.researchTypes) { type in
                        DListButtonCard(
                            title: .forResearchType(type),
                            action: {
                                router.dismissSheet()
                                arguments?.onSelected(type)
                            },
                            isSelected: arguments?.currentValue == type
                        )
                    }
                    .padding(.bottom, size.s8)
                }
                .padding(size.s16)
                .padding(.bottom, size.s116)
            }
        }
        bottom: {
            DText(
                .researchTypeFutureAddingDescription
            )
            .dStyle(
                font: typography.textSmall,
                color: color.grayscalePlacehold,
                alignment: .center
            )
            .padding(size.s16)
        }
    }
}
