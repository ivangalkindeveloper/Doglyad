//
//  Wrapper.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import SwiftUI

public struct DThemeWrapperView<Content: View>: View {
    @StateObject private var theme = DTheme.light
    var child: Content

    public init(
        _ child: Content
    ) {
        self.child = child
    }

    public var body: some View {
        child
            .environmentObject(theme)
    }
}
