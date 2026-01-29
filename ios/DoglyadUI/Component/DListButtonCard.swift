import SwiftUI

public struct DListButtonCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: LocalizedStringResource;
    let action: () -> Void
    let isSelected: Bool
    
    public init(
        title: LocalizedStringResource,
        action: @escaping () -> Void,
        isSelected: Bool
    ) {
        self.title = title
        self.action = action
        self.isSelected = isSelected
    }
    
    public var body: some View {
        DButtonCard(
            action: action
        ) {
            HStack {
                DText(title)
                    .dStyle(
                        font: typography.linkSmall,
                    )
                Spacer()
                if isSelected {
                    DIcon(
                        .check,
                        color: color.successDefault
                    )
                    .padding(.leading, size.s16)
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
