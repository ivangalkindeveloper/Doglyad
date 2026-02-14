import DoglyadUI
import SwiftUI

struct OnBoardingPageView<BottomContent: View>: View {
    @EnvironmentObject var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let tag: OnBoardingViewModel.Page
    let image: ImageResource
    let description: LocalizedStringResource
    let bottomContent: BottomContent

    init(
        tag: OnBoardingViewModel.Page,
        image: ImageResource,
        description: LocalizedStringResource,
        @ViewBuilder bottomContent: @escaping () -> BottomContent = { EmptyView() }
    ) {
        self.tag = tag
        self.image = image
        self.description = description
        self.bottomContent = bottomContent()
    }

    var body: some View {
        VStack(
            spacing: .zero
        ) {            
            Spacer()
            
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth: size.s128,
                    maxHeight: size.s128,
                )
                .padding(size.s16)
            
            Spacer()

            DText(
                description
            )
            .dStyle(
                font: typography.textMedium,
                alignment: .leading
            )

            if !(bottomContent is EmptyView) {
                bottomContent
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .padding(size.s16)
        .padding(.bottom, size.s48)
        .tag(tag)
    }
}
