//
//  ScanBottomSheetViewModel.swift
//  Doglyad
//
//  Created by Иван Галкин on 27.10.2025.
//

import Foundation
import SwiftUI
import BottomSheet

final class ScanSheetViewModel: ObservableObject {
    @Published var sheetPosition: BottomSheetPosition = .hidden
    let sheetPositionHidden: BottomSheetPosition = .hidden
    let sheetPositionBottom: BottomSheetPosition = .absolute(120)
    let sheetPositionTop: BottomSheetPosition = .relativeTop(1)
    
    var isSheetVisible: Bool {
        sheetPosition != sheetPositionHidden
    }
    
    func setHidden() -> Void {
        if self.sheetPosition == sheetPositionHidden { return }
        self.sheetPosition = sheetPositionHidden
    }
    
    func setBottom() -> Void {
        if self.sheetPosition == sheetPositionBottom { return }
        self.sheetPosition = sheetPositionBottom
    }
}
