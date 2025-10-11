//
//  DTheme.swift
//  Doglyad
//
//  Created by Иван Галкин on 11.10.2025.
//

import Combine

public class DTheme: Combine.ObservableObject {
    @Published var color: DColor
    @Published var typography: DTypography
    
    private init(
        color: DColor,
        typography: DTypography
    ) {
        self.color = color
        self.typography = typography
    }
}

public extension DTheme {
    static let light = DTheme(
        color: DColor.light,
        typography: DTypography.default,
    )
    
    func changeColor(
        color: DColor
    ) {
        self.color = color
    }
}
