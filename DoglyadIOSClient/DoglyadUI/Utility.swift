//
//  Utility.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import SwiftUI

extension Color {
    init(
        hex: UInt,
        alpha: Double = 1
    ) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Font {
    static func custom(
        _ family: DFontFamily,
        _ size: CGFloat
    ) -> Font {
        Font.custom(
            family.rawValue,
            fixedSize: size
        )
    }
}
