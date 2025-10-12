//
//  DTypography.swift
//  Doglyad
//
//  Created by Иван Галкин on 11.10.2025.
//

import SwiftUI

public struct DTypography {
    public let displayHuge: Font
    public let displayLarge: Font
    public let displayMedium: Font
    public let displaySmall: Font
    
    public let displayHugeBold: Font
    public let displayLargeBold: Font
    public let displayMediumBold: Font
    public let displaySmallBold: Font
    
    public let textLarge: Font
    public let textMedium: Font
    public let textSmall: Font
    public let textXSmall: Font
    
    public let linkLarge: Font
    public let linkMedium: Font
    public let linkSmall: Font
    public let linkXSmall: Font
}

public extension DTypography {
     static let shared = DTypography(
        displayHuge: .custom(.PoppinsRegular, 32),
        displayLarge: .custom(.PoppinsRegular, 28),
        displayMedium: .custom(.PoppinsRegular, 24),
        displaySmall: .custom(.PoppinsRegular, 20),
        
        displayHugeBold: .custom(.PoppinsBold, 32),
        displayLargeBold: .custom(.PoppinsBold, 28),
        displayMediumBold: .custom(.PoppinsBold, 24),
        displaySmallBold: .custom(.PoppinsBold, 20),
        
        textLarge: .custom(.PoppinsRegular, 20),
        textMedium: .custom(.PoppinsRegular, 17),
        textSmall: .custom(.PoppinsRegular, 14),
        textXSmall: .custom(.PoppinsMedium, 13),
        
        linkLarge: .custom(.PoppinsSemiBold, 20),
        linkMedium: .custom(.PoppinsSemiBold, 17),
        linkSmall: .custom(.PoppinsSemiBold, 14),
        linkXSmall: .custom(.PoppinsSemiBold, 13),
    )
}
