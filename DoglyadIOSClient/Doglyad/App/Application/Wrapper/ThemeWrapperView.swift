//
//  ThemeWrapperView.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import SwiftUI
import DoglyadUI

struct ThemeWrapperView<Content: View>: View  {
    @StateObject private var theme = DTheme.light
    private var child: Content
    
    init(
        _ child: Content
    ) {
        self.child = child
    }
    
    var body: some View {
         child
        .environmentObject(self.theme)
    }
}
