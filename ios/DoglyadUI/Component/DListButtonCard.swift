import SwiftUI

public struct DListButtonCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let title: LocalizedStringResource
    let description: LocalizedStringResource?
    let action: () -> Void
    let isSelected: Bool

    public init(
        title: LocalizedStringResource,
        description: LocalizedStringResource? = nil,
        action: @escaping () -> Void,
        isSelected: Bool = false
    ) {
        self.title = title
        self.description = description
        self.action = action
        self.isSelected = isSelected
    }

    public var body: some View {
        DButtonCard(
            action: action
        ) {
            VStack(
                alignment: .leading,
                spacing: .zero
            ) {
                HStack {
                    DText(title)
                        .dStyle(
                            font: typography.linkSmall
                        )
                    Spacer()
                    if self.isSelected {
                        DIcon(
                            .check,
                            color: color.successDefault
                        )
                        .padding(.leading, size.s16)
                    }
                }
                if let description = self.description {
                    DText(description)
                        .dStyle(
                            font: typography.textXSmall,
                            color: color.grayscalePlacehold
                        )
                        .padding(.top, size.s4)
                }
            }
        }
    }
}

#Preview {
    DThemeWrapperView {
        DListButtonCard(
            title: "Gland research",
            action: {
                print("Gland")
            },
            isSelected: true
        )
        .padding()
    }
}
