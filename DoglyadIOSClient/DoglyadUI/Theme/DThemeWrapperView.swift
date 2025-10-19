//
//  Wrapper.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import SwiftUI

public struct DThemeWrapperView<Content: View>: View {
    @StateObject private var theme = DTheme.light
    @ViewBuilder  let content: () -> Content

    public init(
        content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        content()
            .environmentObject(theme)
    }
}
