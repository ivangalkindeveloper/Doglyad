import SwiftUI
import DoglyadUI

struct ExpandableCard<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let gradientColor: Color
    let content: () -> Content
    
    @State private var isExpanded = false
    @State private var contentHeight: CGFloat = 0
    private var isNeedsExpansion: Bool {
        contentHeight >= collapsedHeight
    }
    private var collapsedHeight: Double {
        size.s128
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            content()
                .if(isNeedsExpansion) { view in
                    view
                        .overlay(collapsedMask)
                        .frame(height: isExpanded ? nil : collapsedHeight)
                }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: HeightKey.self,
                                    value: geo.size.height)
                }
            )
            .onPreferenceChange(HeightKey.self) { height in
                contentHeight = height
            }

            if isNeedsExpansion {
                Button(
                    action: {
                        isExpanded.toggle()
                    }
                ) {
                    HStack(
                        spacing: 0
                    ) {
                        if isExpanded {
                            DText(.buttonCollapse)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.primaryDefault
                                )
                                .padding(.trailing, size.s12)
                            DIcon(
                                .up,
                                color: color.primaryDefault
                            )
                            .frame(
                                width: size.s8,
                                height: size.s8
                            )
                        } else {
                            DText(.buttonExpand)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.primaryDefault
                                )
                                .padding(.trailing, size.s12)
                            DIcon(
                                .down,
                                color: color.primaryDefault
                            )
                            .frame(
                                width: size.s8,
                                height: size.s8
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, size.s16)
                .padding(.bottom, size.s8)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(
            theme.animation,
            value: isExpanded
        )
    }
}

private extension ExpandableCard {
    private var collapsedMask: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                gradientColor.opacity(0),
                gradientColor,
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: collapsedHeight)
        .opacity(isExpanded ? 0 : 1)
    }
}

struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
