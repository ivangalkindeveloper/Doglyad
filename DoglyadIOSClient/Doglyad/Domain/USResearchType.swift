//
//  ResearchType.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

enum USResearchType: String {
    case thyroidGland // Щитовидная железа
    
    static func fromString(_ value: String?) -> USResearchType? {
        switch value {
        case USResearchType.thyroidGland.rawValue:
                .thyroidGland
        default:
            nil
        }
    }
}
