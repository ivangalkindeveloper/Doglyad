import SwiftUI

@Observable
public class DTheme {
    public var color: DColor
    public var size: DSize
    public var typography: DTypography
    public var animation: Animation? = .spring(
        response: 0.5,
        dampingFraction: 0.75,
        blendDuration: 1
    )

    public init(
        color: DColor,
        size: DSize,
        typography: DTypography
    ) {
        self.color = color
        self.size = size
        self.typography = typography
    }
}

public extension DTheme {
    static let light = DTheme(
        color: DColor.light,
        size: DSize.shared,
        typography: DTypography.shared
    )

    func changeColor(
        color: DColor
    ) {
        self.color = color
    }
}
