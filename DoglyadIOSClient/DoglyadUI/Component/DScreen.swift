import SwiftUI

public struct DScreen<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: LocalizedStringResource?
    let subTitle: String?
    let backgroundColor: Color?
    let onTap: (() -> Void)?
    let onTapBack: (() -> Void)?
    let content: () -> Content
    
    public init(
        title: LocalizedStringResource? = nil,
        subTitle: String? = nil,
        backgroundColor: Color? = nil,
        onTap: (() -> Void)? = nil,
        onTapBack: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.title = title
        self.subTitle = subTitle
        self.backgroundColor = backgroundColor
        self.onTap = onTap
        self.onTapBack = onTapBack
        self.content = content
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                if let onTap = self.onTap {
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture{ onTap() }
                }
                content()
            }
            .frame(maxWidth: .infinity)
            .background(backgroundColor ?? color.grayscaleBackgroundWeak)
        }
        .ifLet(title) { view, title in
            view
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarRole(.navigationStack)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            DText(title)
                                .dStyle(
                                    font: typography.linkSmall,
                                )
                            if let subTitle = self.subTitle {
                                DText(subTitle)
                                    .dStyle(
                                        font: typography.textXSmall,
                                        color: color.grayscaleLabel
                                    )
                            }
                        }
                    }
                }
        }
        .ifLet(onTapBack) { view, onTapBack in
            view
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onTapBack()
                        } label: {
                            Image(.back)
                        }
                    }
                }
        }
    }
}
