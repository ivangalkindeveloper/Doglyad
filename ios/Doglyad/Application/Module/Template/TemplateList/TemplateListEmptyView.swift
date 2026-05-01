import DoglyadUI
import SwiftUI

struct TemplateListEmptyView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    var body: some View {
        VStack(
            spacing: .zero
        ) {
            DText(.templateListEmptyDescription)
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlacehold,
                    alignment: .center
                )
                .padding(.bottom, size.s16)
        }
        .padding(.top, size.screenHeight / 4)
    }
}
