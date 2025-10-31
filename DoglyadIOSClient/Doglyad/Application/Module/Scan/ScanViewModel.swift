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
        
        if let usResearchType = diagnosticRepository?.getSelectedUSResearchType() {
            researchType = ResearchType(type: usResearchType)
        }
    }
    
    @NestedObservableObject var cameraController = CameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    @Published var researchType: ResearchType?
    @Published var photos: [ScanPhoto] = []
    @NestedObservableObject var nameController = DInputController()
    @Published var gender: PatientGender?
    @Published var age: Int = 18
    @NestedObservableObject var medicalHistoryController = DInputController()
    @NestedObservableObject var сurrentComplaintController = DInputController()
    
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
    
    func onPressedGender() -> Void {}
    
    func onPressedAge() -> Void {}
    
    func onPressedMedicalHistorySpeechToText() -> Void {}
    
    func onPressedCurrentComplaintSpeechToText() -> Void {}
    
    func onPressedScan() -> Void {}
    
    func unfocus() -> Void {
        nameController.unfocus()
        medicalHistoryController.unfocus()
        сurrentComplaintController.unfocus()
    }
}
