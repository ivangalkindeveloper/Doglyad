import DoglyadUI
import SwiftUI

public struct PhotoCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let image: UIImage
    let actionDelete: (() -> Void)?

    public init(
        image: UIImage,
        actionDelete: (() -> Void)? = nil
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
            .if(actionDelete != nil) { view in
                view
                    .padding(.top, size.s8)
                    .padding(.trailing, size.s8)
                    .overlay(alignment: .topTrailing) {
                        Button(action: actionDelete ?? {}) {
                            ZStack {
                                Circle().fill(color.dangerDefaultWeak)
                                Image(.close)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(color.dangerDefault)
                                    .frame(
                                        width: size.s16,
                                        height: size.s16,
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
}

#Preview {
    DThemeWrapperView {
        PhotoCard(
            image: .alertInfo,
            actionDelete: {}
        )
        .padding()
    }
}
