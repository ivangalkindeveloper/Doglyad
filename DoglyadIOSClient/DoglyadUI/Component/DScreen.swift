//
//  DScreen.swift
//  DoglyadUI
//
//  Created by Иван Галкин on 13.10.2025.
//

import SwiftUI

public struct DScreen<Content: View>: View {
    @EnvironmentObject var theme: DTheme
    let title: String?
    let child: Content
    let bottom: Content?
    
    public init(
        title: String? = nil,
        body: Content,
        bottom: Content? = nil,
    ) {
        self.title = title
        self.child = body
        self.bottom = bottom
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                child
                if let bottom {
                    bottom
                }
            }
            .background(theme.color.grayscaleBackground)
        }
        .ifLet(title) { view, title in
            view
                .navigationTitle(title)
        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Опции") { }
//            }
//        }
    }
}

//#Preview {
//    DScreen()
//}
