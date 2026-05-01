import DoglyadUI
import SwiftUI

struct TemplateListScreenView: View {
    @EnvironmentObject private var theme: DTheme
    @EnvironmentObject private var container: DependencyContainer
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: TemplateListViewModel

    var body: some View {
        DScreen(
            title: .templateListTitle,
            onTapBack: viewModel.onTapBack,
            content: { toolbarInset in
                ZStack(
                    alignment: .bottom
                ) {
                    ScrollView(
                        showsIndicators: false
                    ) {
                        VStack(
                            alignment: .leading,
                            spacing: .zero
                        ) {
                            if viewModel.templates.isEmpty {
                                TemplateListEmptyView()
                            } else {
                                VStack(
                                    spacing: size.s4
                                ) {
                                    ForEach(viewModel.templates) { template in
                                        TemplateListItemCard(
                                            examinationTypeTitle: template.usExaminationType.getLocalizedTitle(
                                                for: Locale.current
                                            ),
                                            templateContent: template.content,
                                            action: {
                                                viewModel.onTapTemplate(template)
                                            }
                                        )
                                    }
                                }
                                .padding(.bottom, size.s16)
                            }
                        }
                        .padding(size.s16)
                        .padding(.top, toolbarInset)
                        .padding(.bottom, size.s64)
                    }
                }
            },
            bottom: {
                DButton(
                    title: .templateListAddButton,
                    action: viewModel.onTapAdd
                )
                .dStyle(.primaryButton)
                .padding(size.s16)
            }
        )
        .onAppear {
            viewModel.onAppear()
        }
        .environmentObject(viewModel)
    }
}
