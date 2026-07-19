import SwiftUI

public struct DBadge<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let title: LocalizedStringResource
    let isVisible: Bool
    let isShimmering: Bool
    let content: () -> Content

    public init(
        _ title: LocalizedStringResource,
        isVisible: Bool = true,
        isShimmering: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isVisible = isVisible
        self.isShimmering = isShimmering
        self.content = content
    }

    public var body: some View {
        content()
            .overlay(alignment: .topTrailing) {
                if isVisible {
                    badge
                        .if(isShimmering) { $0.dShimmer() }
                        .offset(x: size.s10, y: -size.s10)
                }
            }
    }

    private var badge: some View {
        Text(title)
            .font(typography.linkXSmall)
            .foregroundStyle(color.grayscaleBackground)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
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
                DButtonCard(
                    action: {}
                ) {
                    HStack {
                        DText("Shimmering pro badge")
                            .dStyle()
                        Spacer()
                    }
                }
            }

            DBadge("Long badge title") {
                DText("Badge grows to the left")
                    .dStyle()
            }
        }
        .padding()
    }
    .dThemeWrapper()
}
