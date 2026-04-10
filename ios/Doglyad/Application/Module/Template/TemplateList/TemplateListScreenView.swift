import DoglyadUI
import SwiftUI

struct TemplateListScreenView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: TemplateListViewModel

    var body: some View {
        DScreen(
            title: .templateListTitle,
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    alignment: .leading,
                    spacing: .zero
                ) {
                    if viewModel.templates.isEmpty {
                        DText(.templateListEmptyDescription)
                            .dStyle(
                                font: typography.textSmall,
                                color: color.grayscalePlacehold
                            )
                            .padding(.bottom, size.s16)
                    } else {
                        VStack(
                            spacing: size.s4
                        ) {
                            ForEach(viewModel.templates) { template in
                                DListButtonCard(
                                    title: template.usExaminationType.getLocalizedTitle(for: Locale.current),
                                    description: LocalizedStringResource(
                                        stringLiteral: template.content
                                    ),
                                    action: {
                                        viewModel.onTapTemplate(template)
                                    }
                                )
                            }
                        }
                        .padding(.bottom, size.s16)
                    }

                    DButton(
                        title: .templateListAddButton,
                        action: viewModel.onTapAdd
                    )
                    .dStyle(.primaryButton)
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
        }
        .onAppear {
            viewModel.load()
        }
        .environment(viewModel)
    }
}
