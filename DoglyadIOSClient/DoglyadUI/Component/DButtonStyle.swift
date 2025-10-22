//
//  DButtonStyle.swift
//  Doglyad
//
//  Created by Иван Галкин on 20.10.2025.
//

import SwiftUI

public struct DButtonStyle: ButtonStyle {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    
    
    let backgroundColor: Color?
    
    public init(
        backgroundColor: Color? = nil,
    ) {
        self.backgroundColor = backgroundColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(size.s14)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if let backgroundColor = backgroundColor {
                        RoundedRectangle(cornerRadius: size.s16)
                            .fill(backgroundColor)
                    } else {
                        RoundedRectangle(cornerRadius: size.s16)
                            .fill(color.gradientPrimaryWeak)
                    }
                }
            )
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.6: 1)
            .animation(
                .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}
