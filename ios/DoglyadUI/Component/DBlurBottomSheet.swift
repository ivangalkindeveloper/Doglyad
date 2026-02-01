import SwiftUI

public struct DBlurBottomSheet<Content>: View where Content: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    let title: LocalizedStringResource
    let fraction: Double
    let content: () -> Content

    public init(
        title: LocalizedStringResource,
        fraction: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.fraction = fraction
        self.content = content
    }

    public var body: some View {
        VStack(
            spacing: .zero
        ) {
            HStack {
                Color.clear
                    .frame(
                        width: 22,
                        height: .zero
                    )
                Spacer()
                DText(title)
                    .dStyle(
                        font: typography.linkSmall,
                        color: color.grayscaleBackgroundWeak,
                        alignment: .center
                    )
                    .padding(size.s16)
                Spacer()
                DCloseButton {
                    dismiss()
                }
            }
            .padding(.top, size.adaptiveCornerRadius / 4)
            .padding(.horizontal, size.adaptiveCornerRadius / 2)

            content()
        }
        .presentationBackground(.ultraThinMaterial)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(size.adaptiveCornerRadius)
        .presentationDetents([.fraction(fraction)])
    }
}
