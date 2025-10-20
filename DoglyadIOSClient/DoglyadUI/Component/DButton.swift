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
        ) {
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
        .buttonStyle(DButtonStyle())
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
