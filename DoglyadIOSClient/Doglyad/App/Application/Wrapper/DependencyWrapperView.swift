//
//  DependencyContainerWrapperView.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import SwiftUI

struct DependencyWrapperView<Content: View>: View  {
    let dependencyContainer: DependencyContainer
    var child: Content
    
    init(
        dependencyContainer: DependencyContainer,
        _ child: Content
    ) {
        self.dependencyContainer = dependencyContainer
        self.child = child
    }
    
    var body: some View {
         child
        .environmentObject(self.dependencyContainer)
    }
}
