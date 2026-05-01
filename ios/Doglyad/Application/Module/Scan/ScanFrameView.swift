import DoglyadUI
import SwiftUI

struct ScanFrameView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    var body: some View {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height

        GeometryReader { geometry in
            let w = geometry.size.width
            let h = screenHeight / 3

            let color = color.grayscaleBackgroundWeak
            let cornerLength: CGFloat = size.s48
            let lineWidth: CGFloat = size.s8 / 2
            let cornerRadius: CGFloat = size.s48

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                    path.addQuadCurve(
                        to: CGPoint(x: cornerRadius, y: 0),
                        control: CGPoint(x: 0, y: 0)
                    )
                    path.addLine(to: CGPoint(x: cornerLength, y: 0))
                }
                .stroke(color, lineWidth: lineWidth)

                Path { path in
                    path.move(to: CGPoint(x: w - cornerLength, y: 0))
                    path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: w, y: cornerRadius),
                        control: CGPoint(x: w, y: 0)
                    )
                    path.addLine(to: CGPoint(x: w, y: cornerLength))
                }
                .stroke(color, lineWidth: lineWidth)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: h - cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: h - cornerRadius))
                    path.addQuadCurve(
                        to: CGPoint(x: cornerRadius, y: h),
                        control: CGPoint(x: 0, y: h)
                    )
                    path.addLine(to: CGPoint(x: cornerLength, y: h))
                }
                .stroke(color, lineWidth: lineWidth)

                Path { path in
                    path.move(to: CGPoint(x: w - cornerLength, y: h))
                    path.addLine(to: CGPoint(x: w - cornerRadius, y: h))
                    path.addQuadCurve(
                        to: CGPoint(x: w, y: h - cornerRadius),
                        control: CGPoint(x: w, y: h)
                    )
                    path.addLine(to: CGPoint(x: w, y: h - cornerLength))
                }
                .stroke(color, lineWidth: lineWidth)
            }
        }
        .padding(.vertical, screenHeight / 4)
        .padding(size.s16)
    }
}
