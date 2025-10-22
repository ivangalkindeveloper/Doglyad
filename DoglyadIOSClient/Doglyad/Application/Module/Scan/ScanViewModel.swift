//
//  AnamnesisViewModel.swift
//  Doglyad
//
//  Created by Иван Галкин on 06.10.2025.
//

import Foundation
import SwiftUI
import Router

final class ScanViewModel: ObservableObject {
    var diagnosticRepository: DiagnosticsRepositoryProtocol?
    var router: DRouter?
    
    @Published var researchType: ResearchType?
    @Published var photos: [UIImage] = []
    @Published var patientName: String = ""
    @Published var patientGender: PatientGender?
    @Published var patientAge: Int = 18
    @Published var patientAnamnesis: String = ""
    
    func onPressedHisotry() -> Void {
        router?.push(
            route: RouteScreen(
                type: .history
            )
        )
    }
    
    func onPressedResearchType() {
        router?.push(
            route: RouteSheet(
                type: .researchType,
                arguments: ResearchTypeScreenArguments(
                    onSelected: { [weak self] researchType in
                        self?.researchType = researchType
                        self?.diagnosticRepository?.setSelectedUSResearchType(
                            type: researchType.type
                        )
                    }
                )
            )
        )
    }
    
    func capturePhoto(
        image: UIImage
    ) -> Void {
        self.photos.append(image)
    }
    
    func deletePhoto(
        image: UIImage
    ) -> Void {
        self.photos.remove(at: photos.firstIndex(of: image)!)
    }
    
    func onPressedPatientGender() -> Void {}
    
    func onPressedPatientAge() -> Void {}
    
    func onPressedPatientAnamnesisSpeechToText() -> Void {}
    
    func onPressedNext() -> Void {}
}
