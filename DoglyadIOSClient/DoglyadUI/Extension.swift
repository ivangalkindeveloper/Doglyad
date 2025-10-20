//
//  Utility.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import SwiftUI

public extension Color {
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

public extension Font {
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

public extension View {
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifLet<T, Content: View>(
        _ value: T?,
        transform: (Self, T) -> Content
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifLetElse<T, Content: View>(
        _ value: T?,
        transform: (Self, T) -> Content,
        `else`: (Self) -> Content
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            `else`(self)
        }
    }
}
