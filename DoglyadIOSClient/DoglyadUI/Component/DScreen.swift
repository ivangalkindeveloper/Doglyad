//
//  DScreen.swift
//  DoglyadUI
//
//  Created by Иван Галкин on 13.10.2025.
//

import SwiftUI

public struct DScreen<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    
    let title: String?
    @ViewBuilder let content: () -> Content
    
    public init(
        title: String? = nil,
        content: @escaping () -> Content,
    ) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        NavigationView {
            content()
                .background(theme.color.grayscaleBackground)
        }
        .ifLet(title) { view, title in
            view
                .navigationTitle(title)
        }
    }
}
