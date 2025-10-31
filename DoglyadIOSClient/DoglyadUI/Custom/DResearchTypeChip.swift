//
//  DResearchTypeChip.swift
//  Doglyad
//
//  Created by Иван Галкин on 25.10.2025.
//

import SwiftUI

struct DResearchTypeChip: View {
    let title: LocalizedStringResource
    let action: () -> Void

    public init(
        title: LocalizedStringResource,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        DButton(
            title: title,
            action: action
        ).buttonStyle(DButtonStyle(.primaryChip))
    }
}

//#Preview {
//    DThemeWrapperView{
//        DResearchTypeChip(
//            title: "Thyroid gland",
//            action: {}
//        )
//        .padding()
//    }
//}
