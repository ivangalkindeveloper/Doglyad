import DoglyadUI
import SwiftUI

struct ExpandableText: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let text: String
    let backgroundColor: Color

    private let collapsedLineLimit: Int = 3
    @State private var isExpanded = false

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: size.s4
        ) {
            if isExpanded {
                DText(text)
                    .dStyle(
                        font: typography.textSmall,
                        alignment: .leading
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(.buttonCollapse) {
                    withAnimation(theme.animation) {
                        isExpanded.toggle()
                    }
                }
                .font(typography.linkSmall)
                .foregroundColor(color.primaryDefault)
                .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                DText(text)
                    .dStyle(
                        font: typography.textSmall,
                        alignment: .leading
                    )
                    .lineLimit(collapsedLineLimit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .bottomTrailing) {
                        HStack(
                            spacing: .zero
                        ) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            backgroundColor.opacity(0),
                                            backgroundColor
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 80, height: 16)
                                

                            Button(.buttonNext) {
                                withAnimation(theme.animation) {
                                    isExpanded.toggle()
                                }
                            }
                            .font(typography.linkSmall)
                            .foregroundColor(color.primaryDefault)
                            .background(backgroundColor)
                        }
                    }
            }
        }
    }
}

#Preview {
    DThemeWrapperView {
        ExpandableText(
            text: """
            Это длинный текст, который должен быть обрезан после определённого количества строк. \
            При этом в конце текста в свернутом состоянии должно показываться троеточие и слово «Далее», \
            которое является кнопкой и располагается на той же строке, что и окончание усеченного текста. \
            При нажатии текст полностью развернётся.
            """,
            backgroundColor: Color(.white)
        )
        .padding()
    }
}
