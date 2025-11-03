import SwiftUI

public struct DBottomSheet<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

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
        VStack(spacing: .zero) {
            Capsule()
                .fill(color.grayscaleLine)
                .frame(
                    width: 36,
                    height: 5
                )
                .padding(.top, 7.5)
                .padding(.bottom, 7.5)
            
            DText(title)
                .dStyle(
                    font: typography.linkMedium
                )
                .padding(size.s16)
            
            Spacer()
            content()
            Spacer()
        }
        .presentationBackground(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(size.s32)
        .presentationDetents([.fraction(fraction)])
    }
}
