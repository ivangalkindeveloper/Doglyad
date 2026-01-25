import SwiftUI

public struct DIcon: View {
    @EnvironmentObject private var theme: DTheme
    
    let resource: ImageResource
    let color: Color?
    
    public init(
        _ resource: ImageResource,
        color: Color? = nil
    ) {
        self.resource = resource
        self.color = color
    }
    
    public var body: some View {
        Image(resource)
            .renderingMode(.template)
            .foregroundColor(color ?? theme.color.grayscaleHeader)
    }
}

#Preview {
    DIcon(
        .wifi,
        color: .red
    )
}
