//
//  AnamnesisViewModel.swift
//  Doglyad
//
//  Created by Иван Галкин on 06.10.2025.
//

import Foundation
import SwiftUI
import Router
import BottomSheet

final class ScanViewModel: ObservableObject {
    private var diagnosticRepository: DiagnosticsRepositoryProtocol?
    private var router: DRouter?
    
    func initialize(
        container: DependencyContainer,
        router: DRouter
    ) -> Void {
        self.diagnosticRepository = container.diagnosticsRepository
        self.router = router
        
        if let usResearchType = diagnosticRepository?.getSelectedUSResearchType() {
            researchType = ResearchType(type: usResearchType)
        }
    }
    
    @Published var researchType: ResearchType?
    @Published var photos: [ScanPhoto] = []
    @Published var name: String = ""
    @Published var gender: PatientGender?
    @Published var age: Int = 18
    @Published var medicalHistory: String = ""
    @Published var сurrentComplaint: String = ""
    
    func onPressedHistory() -> Void {
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
        photos.append(
            ScanPhoto(image: image)
        )
    }
    
    func onPressedDeletePhoto(
        photo: ScanPhoto
    ) -> Void {
        photos.remove(at: photos.firstIndex(of: photo)!)
    }
    
    func onPressedGender() -> Void {}
    
    func onPressedAge() -> Void {}
    
    func onPressedMedicalHistorySpeechToText() -> Void {}
    
    func onPressedCurrentComplaintSpeechToText() -> Void {}
    
    func onPressedScan() -> Void {}
}
