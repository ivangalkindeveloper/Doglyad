//
//  ResearchTypeViewModel.swift
//  Doglyad
//
//  Created by Иван Галкин on 06.10.2025.
//

import Foundation

final class ResearchTypeViewModel: ObservableObject {    
    var researchTypes: [ResearchType] = [
        ResearchType(
            type: .thyroidGland,
        )
    ]
    
    func onPressedType(
        arguments: ResearchTypeScreenArguments?,
        type: ResearchType,
    ) -> Void {
        arguments?.onSelected(type)
    }
}
