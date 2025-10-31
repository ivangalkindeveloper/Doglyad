//
//  DResearchTypeCard.swift
//  Doglyad
//
//  Created by Иван Галкин on 20.10.2025.
//

import SwiftUI

public struct DListCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: LocalizedStringResource;
    let action: () -> Void
    
    public init(
        title: LocalizedStringResource,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        DCard(
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
    }
}

#Preview {
    DThemeWrapperView {
        DListCard(
            title: "Gland research",
            action: {
                print("Gland")
            },
        )
        .padding()
    }
}
