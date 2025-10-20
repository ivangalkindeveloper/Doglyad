//
//  ResearchType.swift
//  Doglyad
//
//  Created by Иван Галкин on 19.10.2025.
//

import Foundation

struct ResearchType: Identifiable {
    let id: UUID = UUID()
    let type: USResearchType
    let title: L10n
}
