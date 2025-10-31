//
//  ScanBottomSheetViewModel.swift
//  Doglyad
//
//  Created by Иван Галкин on 27.10.2025.
//

import Foundation
import SwiftUI
import BottomSheet

final class ScanSheetController: ObservableObject {
    @Published var currentPosition: BottomSheetPosition = .hidden
    private let sheetPositionHidden: BottomSheetPosition = .hidden
    private let sheetPositionBottom: BottomSheetPosition = .absolute(120)
    private let sheetPositionTop: BottomSheetPosition = .relativeTop(0.9)
    
    var switchablePositions: [BottomSheetPosition] {
        [
            sheetPositionHidden,
            sheetPositionBottom,
            sheetPositionTop,
        ]
    }
    
    var isSheetVisible: Bool {
        currentPosition != sheetPositionHidden
    }
    
    func setHidden() -> Void {
        self.setPosition(sheetPositionHidden)
    }
    
    func setBottom() -> Void {
        self.setPosition(sheetPositionBottom)
    }
    
    func setTop() -> Void {
        self.setPosition(sheetPositionTop)
    }
}

private extension ScanSheetController {
    func setPosition(
        _ newValue: BottomSheetPosition
    ) -> Void {
        if self.currentPosition == newValue { return }
        self.currentPosition = newValue
    }
}
