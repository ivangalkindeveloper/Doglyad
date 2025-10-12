//
//  DButton.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI

public struct DButton: View {
    @EnvironmentObject var theme: DTheme
    let prefix: DIcon?
    let title: String?
    let action: () -> Void
    let isLoading: Bool
    
    public init(
        prefix: DIcon? = nil,
        title: String? = nil,
        action: @escaping () -> Void,
        isLoading: Bool = false,
    ) {
        self.prefix = prefix
        self.title = title
        self.action = action
        self.isLoading = isLoading
    }
    
    public var body: some View {
        Button(
            action: action,
            label: {
                if isLoading {
                    ProgressView()
                } else {
                    DText(
                        title ?? ""
                    )
                    .dStyle(
                        font: theme.typography.linkMedium,
                        color: theme.color.grayscaleBackground,
                    )
                }

            }
        )
        .buttonStyle(DButtonStyle())
    }
}

private struct DButtonStyle: ButtonStyle {
    @EnvironmentObject var theme: DTheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(theme.size.s14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(
                    cornerRadius: theme.size.s16
                )
                    .fill(
                        theme.color.gradientPrimaryWeak.opacity(configuration.isPressed ? 0.6: 1)
                    )
            )
            .foregroundColor(.white)
            .animation(
                .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

#Preview {
    DThemeWrapperView(
        DButton(
            title: "Preview",
            action: {
                
            }
        )
        .padding()
    )
}
