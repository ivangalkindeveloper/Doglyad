import SwiftUI

public struct DCloseButton: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let action: () -> Void

    public init(
        action: @escaping () -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(color.grayscaleLine)
        }
    }
}
