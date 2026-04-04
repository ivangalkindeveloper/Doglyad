import DoglyadUI
import Router
import SwiftUI

struct SelectUSExaminationTypeBottomSheet: View {
    @Environment(DependencyContainer.self) private var container
    @EnvironmentObject private var router: DRouter
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: SelectUSExaminationTypeArguments?

    var body: some View {
        DBottomSheet(
            title: .usExaminationTypeTitle,
            fraction: 0.8
        ) { toolbarHeight in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: .zero
                ) {
                    ForEach(container.usExaminationTypes) { type in
                        DListButtonCard(
                            title: type.getLocalizedTitle(for: Locale.current),
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
                .padding(.top, toolbarHeight)
                .padding(.bottom, size.s116)
            }
        }
        bottom: {
            DText(
                .usExaminationTypeAddingDescription
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
    SelectUSExaminationTypeBottomSheet(
        arguments: nil
    )
    .previewable()
}
