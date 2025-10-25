//
//  DCircleButton.swift
//  Doglyad
//
//  Created by Иван Галкин on 25.10.2025.
//

import SwiftUI

public struct DCircleButton: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let resource: ImageResource
    let action: () -> Void
    let isLoading: Bool
    
    public init(
        resource: ImageResource,
        action: @escaping () -> Void,
        isLoading: Bool = false,
    ) {
        self.resource = resource
        self.action = action
        self.isLoading = isLoading
    }
    
    public var body: some View {
        Button(
            action: action
        ) {
            ZStack {
                Circle()
                    .fill(color.gradientPrimaryWeak)
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: color.grayscaleBackground
                                )
                            )
                    } else {
                        DIcon(
                            resource,
                            color: color.grayscaleBackground
                        )
                    }
                }
                .foregroundColor(color.grayscaleBackground)
                .padding(size.s14)
                .frame(alignment: .center)
            }
        }
        .frame(
            width: size.s64,
            height: size.s64,
        )
    }
}
