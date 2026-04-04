import DoglyadUI
import SwiftUI

struct ScanSpeechAudioMeterView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let level: Float

    var body: some View {
        HStack(
            spacing: size.s4
        ) {
            ForEach(0 ..< 10) { _ in
                Capsule()
                    .fill(color.grayscaleBackgroundWeak)
                    .frame(
                        width: size.s4,
                        height: level == 0.0 ? 4 : CGFloat.random(in: 4 ... 56) * CGFloat(level + 0.2)
                    )
                    .animation(
                        theme.animation,
                        value: level
                    )
            }
        }
        .frame(
            height: size.s24
        )
    }
}
