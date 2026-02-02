import DoglyadUI
import SwiftUI

struct OnBoardingPageView: View {
    @EnvironmentObject var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let description: LocalizedStringResource
    let tag: OnBoardingViewModel.Page

    var body: some View {
        DText(
            description
        )
        .dStyle(
            font: typography.textMedium,
            alignment: .center
        )
        .padding(size.s16)
        .tag(tag)
    }
}
