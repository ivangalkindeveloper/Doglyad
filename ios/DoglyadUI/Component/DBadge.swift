import SwiftUI

public struct DBadge<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let title: String
    let isShimmering: Bool
    let content: () -> Content

    public init(
        _ title: String,
        isShimmering: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isShimmering = isShimmering
        self.content = content
    }

    @State private var edgeOffset: CGFloat = 0

    public var body: some View {
        content()
            .overlay(alignment: .topTrailing) {
                badge
                    .if(isShimmering) { $0.dShimmer() }
                    .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                    .alignmentGuide(.trailing) { $0[HorizontalAlignment.center] }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(
                                    of: proxy.frame(in: .global).maxX,
                                    initial: true
                                ) { _, maxX in
                                    let limit = size.screenWidth - size.s16
                                    let naturalMaxX = maxX - edgeOffset
                                    edgeOffset = naturalMaxX > limit ? limit - naturalMaxX : 0
                                }
                        }
                    )
                    .offset(x: edgeOffset)
            }
    }

    private var badge: some View {
        Text(verbatim: title)
            .font(typography.linkXSmall)
            .foregroundStyle(color.grayscaleBackground)
            .lineLimit(1)
            .padding(.horizontal, size.s8)
            .padding(.vertical, size.s2)
            .background(
                Capsule()
                    .fill(color.gradientPrimary)
            )
    }
}

#Preview {
    DScreen { _ in
        VStack(spacing: 32) {
            DBadge("New") {
                DButtonCard(
                    action: {}
                ) {
                    HStack {
                        DText("Card with badge")
                            .dStyle()
                        Spacer()
                    }
                }
            }

            DBadge("Pro", isShimmering: true) {
                DText("Badged text")
                    .dStyle()
            }

            DBadge("New") {
                DButtonCard(
                    action: {}
                ) {
                    HStack {
                        DText("Card with badge")
                            .dStyle()
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    .dThemeWrapper()
}
