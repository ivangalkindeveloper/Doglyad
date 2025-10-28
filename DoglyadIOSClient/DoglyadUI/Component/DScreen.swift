//
//  DScreen.swift
//  DoglyadUI
//
//  Created by Иван Галкин on 13.10.2025.
//

import SwiftUI

public struct DScreen<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    
    let title: String?
    let backgroundColor: Color?
    let onTap: (() -> Void)?
    let content: () -> Content
    
    public init(
        title: String? = nil,
        backgroundColor: Color? = nil,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.onTap = onTap
        self.content = content
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                if let onTap = self.onTap {
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture{ onTap() }
                }
                content()
                    .background(backgroundColor ?? color.grayscaleBackgroundWeak)
            }
        }
        .ifLet(title) { view, title in
            view.navigationTitle(title)
        }
    }
}
