//
//  DButton.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI

public struct DPrimaryButton: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
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
                HStack {
                    if let prefix = self.prefix {
                        prefix
                    }
                    if prefix != nil && title != nil {
                        EmptyView()
                            .padding(size.s10)
                    }
                    if let title = self.title {
                        DText(title)
                            .dStyle(
                                font: typography.linkSmall,
                                color: color.grayscaleBackground,
                            )
                    }
                }
            }
        }
        .buttonStyle(DButtonStyle(.primaryButton))
    }
}

#Preview {
    @Previewable @State var isLoading = false

    DThemeWrapperView {
        DPrimaryButton(
            title: "Preview",
            action: {
                isLoading = !isLoading
            },
            isLoading: isLoading
        )
        .padding()
    }
}
