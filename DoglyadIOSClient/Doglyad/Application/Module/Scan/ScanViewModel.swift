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
import DoglyadUI

final class ScanViewModel: ObservableObject {
    static let photoMaxCount: Int = 10
    
    private var diagnosticRepository: DiagnosticsRepositoryProtocol?
    private var router: DRouter?
    
    func initialize(
        container: DependencyContainer,
        router: DRouter
    ) -> Void {
        self.diagnosticRepository = container.diagnosticsRepository
        self.router = router
        if let storedResearchType = diagnosticRepository?.getSelectedResearchType() {
            self.researchType = storedResearchType
        }
    }
    
    @NestedObservableObject var cameraController = CameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    @Published var researchType = ResearchType.default
    @Published var photos: [ScanPhoto] = []
    @NestedObservableObject var patientNameController = DInputController(initialText: "Пациент№0")
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    @NestedObservableObject var patientComplaintController = DInputController()
    
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
                        guard let self = self else { return }
                        self.researchType = researchType
                        self.diagnosticRepository?.setSelectedResearchType(
                            type: researchType
                        )
                    }
                )
            )
        )
    }
    
    var captureIcon: ImageResource {
        photos.count == ScanViewModel.photoMaxCount ? .down : .camera
    }
    
    func onPressedCapture() -> Void {
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
        
        cameraController.takePhoto(
            completion: { [weak self] image in
                guard let self = self else { return }
                photos.append(
                    ScanPhoto(image: image)
                )
                if photos.count == ScanViewModel.photoMaxCount {
                    sheetController.setTop()
                }
            }
        )
    }
    
    func determineOpeningSheet() -> Void {
        if photos.isEmpty {
            return sheetController.setHidden()
        }
        
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
        
        sheetController.setBottom()
    }

    func onPressedDeletePhoto(
        photo: ScanPhoto
    ) -> Void {
        photos.remove(at: photos.firstIndex(of: photo)!)
    }
    
    func onPressedGender(value: PatientGender) -> Void {
        patientGender = value
    }
    
    func onPressedAge() -> Void {}
    
    func onPressedMedicalHistorySpeechToText() -> Void {}
    
    func onPressedCurrentComplaintSpeechToText() -> Void {}
    
    func onPressedScan() -> Void {}
    
    func unfocus() -> Void {
        patientNameController.unfocus()
        patientComplaintController.unfocus()
    }
}
