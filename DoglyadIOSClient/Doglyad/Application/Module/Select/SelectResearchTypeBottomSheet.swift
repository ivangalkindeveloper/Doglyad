import SwiftUI
import Router
import DoglyadUI

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
            fraction: 0.5
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
                    .padding(.bottom, size.s4)
                    
                    DText(
                        .researchTypeFutureAddingDescription
                    )
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscalePlaceholder,
                        alignment: .center
                    )
                    .padding(.top, size.s12)
                    .padding(.bottom, size.s32)
                }
                .padding(size.s16)
            }
        }
    }
}
