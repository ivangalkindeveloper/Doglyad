import Foundation
import SwiftUI
import BottomSheet

@MainActor
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
    
    var isHidden: Bool {
        currentPosition == sheetPositionHidden
    }
    
    var isBottom: Bool {
        currentPosition == sheetPositionBottom
    }
    
    var isTop: Bool {
        currentPosition == sheetPositionTop
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
