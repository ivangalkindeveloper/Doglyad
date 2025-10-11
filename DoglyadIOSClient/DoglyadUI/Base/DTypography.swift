//
//  DTypography.swift
//  Doglyad
//
//  Created by Иван Галкин on 11.10.2025.
//

import SwiftUI

public struct DTypography {
    let displayHuge: Font
    let displayLarge: Font
    let displayMedium: Font
    let displaySmall: Font
    let displayHugeBold: Font
    let displayLargeBold: Font
    let displayMediumBold: Font
    let displaySmallBold: Font
    
    let textLarge: Font
    let textMedium: Font
    let textSmall: Font
    let textXSmall: Font
    
    let linkLarge: Font
    let linkMedium: Font
    let linkSmall: Font
    let linkXSmall: Font
    
    public static let `default` = DTypography(
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
