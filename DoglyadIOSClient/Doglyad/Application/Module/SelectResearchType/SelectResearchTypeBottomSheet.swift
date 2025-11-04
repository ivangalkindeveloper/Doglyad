import SwiftUI
import Router
import DoglyadUI

final class SelectResearchTypeScreenArguments: RouteArgumentsProtocol {
    let onSelected: (ResearchType) -> Void
    
    init(
        onSelected: @escaping (ResearchType) -> Void
    ) {
        self.onSelected = onSelected
    }
}
    
struct SelectResearchTypeBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: SelectResearchTypeScreenArguments?
    @StateObject private var viewModel = SelectResearchTypeViewModel()
    
    var body: some View {
        DBottomSheet(
            title: .researchTypeTitle,
        ) {
            VStack(spacing: .zero) {
                ForEach(viewModel.researchTypes) { type in
                    DListCard(
                        title: .forResearchType(type),
                        action: {
                            dismiss()
                            viewModel.onPressedType(
                                arguments: arguments,
                                type: type
                            )
                        }
                    )
                }
                .padding(.bottom, size.s16)
                
                DText(
                    .researchTypeFutureAddingDescription
                )
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlaceholder,
                    alignment: .center
                )
            }
            .padding(size.s16)
        }
    }
}


//#Preview {
//    ApplicationWrapperView {
//        DThemeWrapperView {
//            ResearchTypeBottomSheet(
//                arguments: nil
//            )
//        }
//    }
//}
