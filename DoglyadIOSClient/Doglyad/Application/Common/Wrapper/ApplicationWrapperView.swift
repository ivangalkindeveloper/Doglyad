//
//  ApplicationWrapperView.swift
//  Doglyad
//
//  Created by Иван Галкин on 18.10.2025.
//

import SwiftUI

struct ApplicationWrapperView<Content: View>: View  {
    let viewModel: ApplicationViewModel
    var child: Content
    
    init(
        viewModel: ApplicationViewModel = ApplicationViewModel(),
        _ child: Content
    ) {
        self.viewModel = viewModel
        self.child = child
    }
    
    var body: some View {
         child
        .environmentObject(self.viewModel)
    }
}
