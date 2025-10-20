//
//  DBottomSheet.swift
//  Doglyad
//
//  Created by Иван Галкин on 19.10.2025.
//

import SwiftUI

public struct DBottomSheet<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: String
    let content: () -> Content
//    @State var detentHeight: CGFloat = 0
    
    public init(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        VStack(
            spacing: 0
        ) {
            DText(title)
                .dStyle(
                    font: typography.linkMedium
                )
                .padding(size.s16)
            Spacer()
            content()
            Spacer()
        }
        .background(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(size.s20)
        .presentationDetents([.fraction(0.3)])
//        .readHeight()
//        .onPreferenceChange(HeightPreferenceKey.self) { height in
//            if let height {
//                self.detentHeight = height
//            }
//        }
//        .presentationBackground(.thinMaterial)
//        .presentationDetents([.height(self.detentHeight)])
    }
}

//fileprivate struct HeightPreferenceKey: PreferenceKey {
//    static var defaultValue: CGFloat?
//
//    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
//        guard let nextValue = nextValue() else { return }
//        value = nextValue
//    }
//}
//
//fileprivate struct ReadHeightModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content.background(sizeView)
//    }
//    
//    private var sizeView: some View {
//        GeometryReader { geometry in
//            Color.clear.preference(
//                key: HeightPreferenceKey.self,
//                value: geometry.size.height
//            )
//        }
//    }
//}
//
//fileprivate extension View {
//    func readHeight() -> some View {
//        self.modifier(ReadHeightModifier())
//    }
//}
