//
//  DResearchTypeCard.swift
//  Doglyad
//
//  Created by Иван Галкин on 20.10.2025.
//

import SwiftUI

public struct DResearchTypeCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: String;
    let action: () -> Void
    
    public init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(
            action: action
        ) {
            HStack {
                DText(title)
                    .dStyle(
                        font: typography.linkSmall,
                    )
                Spacer()
            }

        }
        .buttonStyle(DButtonStyle(
            backgroundColor: color.grayscaleBackground
        ))
    }
}

#Preview {
    DThemeWrapperView {
        DResearchTypeCard(
            title: "Gland research",
            action: {
                print("Gland")
            },
        )
        .padding()
    }
}
