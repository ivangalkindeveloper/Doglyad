import SwiftUI

public struct DBottomSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
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
                        font: typography.linkSmall
                    )
                    .padding(size.s16)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(color.grayscaleLine)
                }
            }
            .padding(.top, size.s8)
            .padding(.horizontal, size.s16)

            content()
        }
        .ignoresSafeArea()
        .presentationBackground(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(size.s32)
        .presentationDetents([.fraction(fraction)])
    }
}


#Preview {
    DThemeWrapperView {
        DBottomSheet(
            title: "Some title"
        ) {
            
        }
    }
    .background(Color.gray)
}
