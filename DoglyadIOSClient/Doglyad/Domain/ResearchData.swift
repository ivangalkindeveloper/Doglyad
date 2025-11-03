//
//  ResearchData.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import Foundation

struct ResearchData {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ScanPhoto]
    let personalData: PatientPersonalData
    let anamnesis: PatientAnamnesis
}
