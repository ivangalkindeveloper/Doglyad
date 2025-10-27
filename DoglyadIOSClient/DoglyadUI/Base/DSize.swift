//
//  DSize.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import Foundation

public struct DSize {
    public let s4: CGFloat = 4
    public let s8: CGFloat = 8
    public let s10: CGFloat = 10
    public let s11: CGFloat = 11
    public let s12: CGFloat = 12
    public let s13: CGFloat = 13
    public let s14: CGFloat = 14
    public let s15: CGFloat = 15
    public let s16: CGFloat = 16
    public let s18: CGFloat = 18
    public let s20: CGFloat = 20
    public let s24: CGFloat = 24
    public let s32: CGFloat = 32
    public let s36: CGFloat = 36
    public let s40: CGFloat = 40
    public let s48: CGFloat = 48
    public let s56: CGFloat = 56
    public let s64: CGFloat = 64
    public let s96: CGFloat = 96
    public let s128: CGFloat = 128
}

public extension DSize {
    static let shared = DSize()
}
