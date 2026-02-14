import SwiftUI

public struct DButton: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let image: ImageResource?
    let title: LocalizedStringResource?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    public init(
        image: ImageResource? = nil,
        title: LocalizedStringResource? = nil,
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.image = image
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }

    public var body: some View {
        Button(
            action: isLoading || isDisabled ? {} : action
        ) {
            if isLoading {
                ProgressView()
            } else {
                HStack(spacing: .zero) {
                    if let image = self.image {
                        Image(image)
                            .renderingMode(.template)
                            .resizable()
                            .frame(
                                width: size.s20,
                                height: size.s20
                            )
                            .if(title != nil) { view in
                                view.padding(.trailing, size.s10)
                            }
                    }
                    if let title = self.title {
                        Text(title)
                            .font(typography.linkSmall)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .disabled(isDisabled)
        .animation(
            theme.animation,
            value: isLoading
        )
    }
}

public extension DButton {
    func dStyle(
        _ type: DButtonStyleType
    ) -> some View {
        modifier(DTextModifier(type: type))
    }
}

private struct DTextModifier: ViewModifier {
    let type: DButtonStyleType

    init(
        type: DButtonStyleType
    ) {
        self.type = type
    }

    func body(content: Content) -> some View {
        content
            .buttonStyle(DButtonStyle(type))
    }
}

#Preview {
    @Previewable @State var isLoading = false

    DScreen { _ in
        VStack {
            DButton(
                image: .bag,
                title: "Primary button",
                action: { isLoading.toggle() },
                isLoading: isLoading
            )
            .dStyle(.primaryButton)

            DButton(
                image: .camera,
                action: { isLoading.toggle() },
                isLoading: isLoading
            )
            .dStyle(.primaryCircle)

            DButton(
                image: .alertInfo,
                title: "Primary chip",
                action: { isLoading.toggle() },
                isLoading: isLoading
            )
            .dStyle(.primaryChip)

            DButton(
                image: .alertInfo,
                action: { isLoading.toggle() },
                isLoading: isLoading
            )
            .dStyle(.circle)

            DButton(
                image: .atSign,
                title: "Some card",
                action: { isLoading.toggle() },
                isLoading: isLoading
            )
            .dStyle(.card)

            DButton(
                image: .bag,
                title: "Disabled button",
                action: {},
                isDisabled: true
            )
            .dStyle(.primaryButton)
        }
        .padding()
    }
    .dThemeWrapper()
}
