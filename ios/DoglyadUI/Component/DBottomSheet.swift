import SwiftUI

public enum DBottomSheetType {
    case `default`
    case blur
}

public struct DBottomSheet<Content, Bottom>: View where Content: View, Bottom: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let type: DBottomSheetType
    let title: LocalizedStringResource
    let fraction: Double
    let content: () -> Content
    let bottom: (() -> Bottom)?

    public init(
        type: DBottomSheetType = .default,
        title: LocalizedStringResource,
        fraction: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder bottom: @escaping () -> Bottom
    ) {
        self.type = type
        self.title = title
        self.fraction = fraction
        self.content = content
        self.bottom = bottom
    }

    public init(
        type: DBottomSheetType = .default,
        title: LocalizedStringResource,
        fraction: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content
    ) where Bottom == EmptyView {
        self.type = type
        self.title = title
        self.fraction = fraction
        self.content = content
        bottom = nil
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
                        color: type == .blur ? color.grayscaleBackgroundWeak : nil,
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

            ZStack {
                content()

                VStack(
                    spacing: .zero
                ) {
                    Spacer()
                    if let bottom = self.bottom?() {
                        bottom
                            .padding(.vertical, size.adaptiveCornerRadius / 6)
                            .frame(maxWidth: .infinity)
                            .safeAreaPadding(.bottom)
                            .background(
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .clipShape(
                                        DRoundedCorner(
                                            radius: size.adaptiveCornerRadius,
                                            corners: [.topLeft, .topRight]
                                        )
                                    )
                            )
                            .transition(.move(edge: .bottom))
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .presentationBackground { presentationBackgroundView }
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(size.adaptiveCornerRadius)
        .presentationDetents([.fraction(fraction)])
        .if(type == .blur) {
            $0.preferredColorScheme(.dark)
        }
    }

    @ViewBuilder
    private var presentationBackgroundView: some View {
        switch type {
        case .default:
            color.grayscaleBackgroundWeak
        case .blur:
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false

    Button("Show Sheet") {
        isPresented = true
    }
    .sheet(isPresented: $isPresented) {
        DBottomSheet(
            title: "Sheet Title",
            fraction: 0.4
        ) {
            VStack(spacing: 12) {
                DText("Bottom sheet content")
                    .dStyle()
                DText("Some description text")
                    .dStyle()
            }
            .padding()
        } bottom: {
            DButton(
                title: "Confirm",
                action: { isPresented = false }
            )
            .dStyle(.primaryButton)
            .padding(.horizontal)
        }
        .dThemeWrapper()
    }
}
