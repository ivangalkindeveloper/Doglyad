//
//  DButton.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI

public struct DButton: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var typography: DTypography { theme.typography }
    
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
            action: isLoading ? {} : action,
            label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: color.grayscaleBackground
                            )
                        )
                } else {
                    DText(
                        title ?? ""
                    )
                    .dStyle(
                        font: typography.linkSmall,
                        color: color.grayscaleBackground,
                    )
                }

            }
        )
        .buttonStyle(DButtonStyle())
    }
}

private struct DButtonStyle: ButtonStyle {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(size.s14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(
                    cornerRadius: size.s16
                )
                    .fill(
                        color.gradientPrimaryWeak.opacity(configuration.isPressed ? 0.6: 1)
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
    @Previewable @State var isLoading = false
    
    DThemeWrapperView {
        DButton(
            title: "Preview",
            action: {
                isLoading = !isLoading
            },
            isLoading: isLoading
        )
        .padding()
    }
}
