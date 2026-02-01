import SwiftUI

public enum DScreenToolbarType {
    case solid, blur
}

public struct DScreen<Leading: View, Title: View, Trailing: View, Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State private var toolbarHeight: CGFloat = 0

    let toolbarType: DScreenToolbarType
    let title: LocalizedStringResource?
    let subTitle: String?
    let backgroundColor: Color?
    let onTapBack: (() -> Void)?
    let leading: Leading
    let titleContent: Title
    let trailing: Trailing
    let onTapBody: (() -> Void)?
    let content: (CGFloat) -> Content

    public init(
        toolbarType: DScreenToolbarType = .solid,
        title: LocalizedStringResource? = nil,
        subTitle: String? = nil,
        backgroundColor: Color? = nil,
        onTapBack: (() -> Void)? = nil,
        @ViewBuilder leading: @escaping (() -> Leading) = { EmptyView() },
        @ViewBuilder titleContent: @escaping (() -> Title) = { EmptyView() },
        @ViewBuilder trailing: @escaping (() -> Trailing) = { EmptyView() },
        onTapBody: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.toolbarType = toolbarType
        self.title = title
        self.subTitle = subTitle
        self.backgroundColor = backgroundColor
        self.onTapBack = onTapBack
        self.leading = leading()
        self.titleContent = titleContent()
        self.trailing = trailing()
        self.onTapBody = onTapBody
        self.content = content
    }

    public var body: some View {
        NavigationView {
            GeometryReader { proxy in
                let safeAreaInsetTop = proxy.safeAreaInsets.top

                ZStack(
                    alignment: .top
                ) {
                    bodyView(toolbarHeight - safeAreaInsetTop)
                    if isShowsToolbar {
                        toolbarView(safeAreaInsetTop)
                            .onPreferenceChange(ToolbarHeightPreferenceKey.self) { value in
                                if toolbarHeight != value {
                                    toolbarHeight = value
                                }
                            }
                            .onChange(of: isShowsToolbar) { _, value in
                                if !value {
                                    toolbarHeight = 0
                                }
                            }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var isShowsToolbar: Bool {
        title != nil
            || subTitle != nil
            || onTapBack != nil
            || !(leading is EmptyView)
            || !(titleContent is EmptyView)
            || !(trailing is EmptyView)
    }

    private func bodyView(
        _ toolbarHeight: CGFloat
    ) -> some View {
        ZStack {
            if let onTapBody = onTapBody {
                Color.clear
                    .onTapGesture { onTapBody() }
            }
            content(toolbarHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor ?? color.grayscaleBackgroundWeak)
    }

    private func toolbarView(
        _ safeAreaInsetTop: CGFloat
    ) -> some View {
        VStack(
            spacing: .zero
        ) {
            HStack(
                spacing: size.s12
            ) {
                leadingView
                Spacer()
                titleView
                    .padding(.horizontal, size.s8)
                Spacer()
                trailingView
            }
            .padding(.top, size.s2 + safeAreaInsetTop)
            .padding(.horizontal, size.adaptiveCornerRadius / 4)
            .padding(.bottom, size.adaptiveCornerRadius / 4)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background {
            toolbarTypeBackground()
                .clipShape(DRoundedCorner(
                    radius: size.adaptiveCornerRadius,
                    corners: [.bottomLeft, .bottomRight]
                ))
        }
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: ToolbarHeightPreferenceKey.self,
                        value: proxy.size.height
                    )
            }
        }
        .ignoresSafeArea(.container, edges: [.top])
    }

    @ViewBuilder
    private func toolbarTypeBackground() -> some View {
        switch toolbarType {
        case .solid:
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                    .opacity(0.8)
                Rectangle().fill(color.grayscaleBackground)
                    .opacity(0.8)
            }
        case .blur:
            Rectangle().fill(.ultraThinMaterial)
        }
    }

    private var leadingView: some View {
        HStack(
            spacing: size.s8
        ) {
            if let onTapBack = onTapBack {
                DButton(
                    image: .back,
                    action: onTapBack
                )
                .dStyle(.circle)
            }
            if !(leading is EmptyView) {
                leading
            }
        }
        .frame(width: size.s56, height: size.s56)
    }

    private var titleView: some View {
        VStack(
            spacing: .zero
        ) {
            if !(titleContent is EmptyView) {
                titleContent
            }
            if let title = title {
                DText(title)
                    .dStyle(
                        font: typography.linkSmall,
                        alignment: .center
                    )
            }
            if let subTitle = subTitle {
                DText(subTitle)
                    .dStyle(
                        font: typography.textXSmall,
                        color: color.grayscaleLabel,
                        alignment: .center
                    )
            }
        }
    }

    private var trailingView: some View {
        HStack(
            spacing: size.s8
        ) {
            if !(trailing is EmptyView) {
                trailing
            }
        }
        .frame(width: size.s56, height: size.s56)
    }
}

private struct ToolbarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
