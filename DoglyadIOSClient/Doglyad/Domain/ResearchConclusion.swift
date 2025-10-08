//
//  ResearchConclusion.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import Foundation

struct ResearchConclusion {
    let timestamp: Date
    let researchType: UltraSoundResearhType
    let photos: [ScanPhoto]
    let personalData: PatientPersonalData
    let anamnesis: PatientAnamnesis
    let modelConclusions: [ModelConclusion]
}
