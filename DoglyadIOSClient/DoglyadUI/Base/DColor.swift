//
//  DColor.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI

public struct DColor {
    let primaryDefault: Color
    let primaryDefaultStrong: Color
    let primaryDefaultWeak: Color
    let primaryBackgroundStrong: Color
    
    let grayscaleHeader: Color
    let grayscaleHeaderWeak: Color
    let grayscaleBody: Color
    let grayscaleLabel: Color
    let grayscalePlaceholder: Color
    let grayscaleLine: Color
    let grayscaleInput: Color
    let grayscaleBackgroundWeak: Color
    let grayscaleBackground: Color
    
    let secondaryDefault: Color
    let secondaryDefaultStrong: Color
    let secondaryDefaultWeak: Color
    let secondaryBackgroundStrong: Color
    let secondaryBackground: Color
    
    let successDefault: Color
    let successDefaultStrong: Color
    let successDefaultWeak: Color
    let successBackgroundStrong: Color
    let successBackground: Color
    
    let warningDefault: Color
    let warningDefaultStrong: Color
    let warningDefaultWeak: Color
    let warningBackgroundStrong: Color
    let warningBackground: Color
    
    let dangerDefault: Color
    let dangerDefaultStrong: Color
    let dangerDefaultWeak: Color
    let dangerBackgroundStrong: Color
    let dangerBackground: Color
}

public extension DColor {
    static let light = DColor(
        primaryDefault: Color(hex: 0x610BEF),
        primaryDefaultStrong: Color(hex: 0x4700AB),
        primaryDefaultWeak: Color(hex: 0xA996FF),
        primaryBackgroundStrong: Color(hex: 0xBFBEFC),
        
        grayscaleHeader: Color(hex: 0x14142B),
        grayscaleHeaderWeak: Color(hex: 0x262338),
        grayscaleBody: Color(hex: 0x4E4B66),
        grayscaleLabel: Color(hex: 0x6E7191),
        grayscalePlaceholder: Color(hex: 0xA0A3BD),
        grayscaleLine: Color(hex: 0xD9DBE9),
        grayscaleInput: Color(hex: 0xEFF0F6),
        grayscaleBackgroundWeak: Color(hex: 0xF7F7FC),
        grayscaleBackground: Color(hex: 0xFCFCFC),

        secondaryDefault: Color(hex: 0x005BD4),
        secondaryDefaultStrong: Color(hex: 0x0041AC),
        secondaryDefaultWeak: Color(hex: 0x50C8FC),
        secondaryBackgroundStrong: Color(hex: 0x8DE9FF),
        secondaryBackground: Color(hex: 0xE3FEFF),

        successDefault: Color(hex: 0x008A00),
        successDefaultStrong: Color(hex: 0x067306),
        successDefaultWeak: Color(hex: 0xA6F787),
        successBackgroundStrong: Color(hex: 0xCBFFAE),
        successBackground: Color(hex: 0xEAF9DE),

        warningDefault: Color(hex: 0xEAAC30),
        warningDefaultStrong: Color(hex: 0x946300),
        warningDefaultWeak: Color(hex: 0xFFDF9A),
        warningBackgroundStrong: Color(hex: 0xFFE6B0),
        warningBackground: Color(hex: 0xFFF8E9),

        dangerDefault: Color(hex: 0xCA024F),
        dangerDefaultStrong: Color(hex: 0x9E0038),
        dangerDefaultWeak: Color(hex: 0xFF75CB),
        dangerBackgroundStrong: Color(hex: 0xFFABE8),
        dangerBackground: Color(hex: 0xFFECFC),
    )
}
