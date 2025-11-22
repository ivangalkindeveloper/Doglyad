import SwiftUI

public struct DBottomSheet<Content, Bottom>: View where Content: View, Bottom: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let title: LocalizedStringResource
    let fraction: Double
    let content: () -> Content
    let bottom: (() -> Bottom)?

    public init(
        title: LocalizedStringResource,
        fraction: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder bottom: @escaping () -> Bottom,
    ) {
        self.title = title
        self.fraction = fraction
        self.content = content
        self.bottom = bottom
    }
    
    public init(
        title: LocalizedStringResource,
        fraction: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content,
    ) where Bottom == EmptyView {
        self.title = title
        self.fraction = fraction
        self.content = content
        self.bottom = nil
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
                        alignment: .center
                    )
                    .padding(size.s16)
                Spacer()
                DCloseButton {
                    dismiss()
                }
            }
            .padding(.top, size.s8)
            .padding(.horizontal, size.s16)
            
            ZStack {
                content()
                
                VStack(
                    spacing: .zero
                ) {
                    Spacer()
                    if let bottom = self.bottom?() {
                        bottom
                        .frame(maxWidth: .infinity)
                        .safeAreaPadding(.bottom)
                        .background(
                            color.grayscaleBackground
                                .clipShape(
                                    DRoundedCorner(
                                        radius: size.s32,
                                        corners: [.topLeft, .topRight]
                                    )
                                )
                                .shadow(color: color.grayscaleBody.opacity(0.2), radius: size.s16)
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .presentationBackground(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(size.s32)
        .presentationDetents([.fraction(fraction)])
    }
}
