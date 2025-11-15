import SwiftUI

public struct DText: View {
    let data: LocalizedStringResource?
    let label: String?
    
    public init(
        _ data: LocalizedStringResource,
    ) {
        self.data = data
        self.label = nil
    }
    
    public init(
        _ label: String,
    ) {
        self.data = nil
        self.label = label
    }
    
    public var body: some View {
        if let data = self.data {
            Text(data)
        }
        if let label = self.label {
            Text(label)
        }
    }
}

public extension DText {
    func dStyle(
        font: Font? = nil,
        color: Color? = nil,
        alignment: TextAlignment? = nil,
    ) -> some View {
        self.modifier(DTextModifier(
            font: font,
            color: color,
            alignment: alignment,
        ))
    }
}

private struct DTextModifier: ViewModifier {
    @EnvironmentObject private var theme: DTheme
    private var typography: DTypography { theme.typography }
    
    let font: Font?
    let color: Color?
    let alignment: TextAlignment?
    
    init(
        font: Font?,
        color: Color?,
        alignment: TextAlignment?,
    ) {
        self.font = font
        self.color = color
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .font(font ?? typography.textMedium)
            .foregroundStyle(color ?? theme.color.grayscaleHeader)
            .multilineTextAlignment(alignment ?? .leading)
    }
}

#Preview {
    DThemeWrapperView {
        DText(
            "Hello, World!",
        )
    }
}
