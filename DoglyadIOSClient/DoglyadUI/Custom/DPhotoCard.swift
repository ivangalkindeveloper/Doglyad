//
//  DPhotoCard.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI

public struct DPhotoCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let image: UIImage
    let actionDelete: () -> Void

    public init(
        image: UIImage,
        actionDelete: @escaping () -> Void
    ) {
        self.image = image
        self.actionDelete = actionDelete
    }

    public var body: some View {
        Image(uiImage: image)
            .resizable()
            .frame(
                width: size.s64,
                height: size.s64
            )
            .aspectRatio(contentMode: .fill)
            .cornerRadius(size.s16)
            .padding(.top, size.s8)
            .padding(.trailing, size.s8)
            .overlay(alignment: .topTrailing) {
                Button(action: actionDelete) {
                    ZStack {
                        Circle().fill(color.dangerDefaultWeak)
                        Image(.close)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(color.dangerDefault)
                            .frame(
                                width: size.s20,
                                height: size.s20,
                            )
                    }
                }
                .frame(
                    width: size.s24,
                    height: size.s24
                )
                .buttonStyle(PlainButtonStyle())
            }
    }
}

#Preview {
    DThemeWrapperView {
        DPhotoCard(
            image: .alertInfo,
            actionDelete: {}
        )
        .padding()
    }
}
