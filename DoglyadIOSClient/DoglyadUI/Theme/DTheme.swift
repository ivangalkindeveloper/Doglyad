//
//  DTheme.swift
//  Doglyad
//
//  Created by Иван Галкин on 11.10.2025.
//

import Combine

public class DTheme: Combine.ObservableObject {
    @Published public var color: DColor
    @Published public var size: DSize
    @Published public var typography: DTypography
    
    init(
        color: DColor,
        size: DSize,
        typography: DTypography
    ) {
        self.color = color
        self.size = size
        self.typography = typography
    }
}

public extension DTheme {
    static let light = DTheme(
        color: DColor.light,
        size: DSize.shared,
        typography: DTypography.shared,
    )
    
    func changeColor(
        color: DColor
    ) {
        self.color = color
    }
}
