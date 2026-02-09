import DoglyadUI
import Shimmer
import SwiftUI

struct WebDocumentBottomSheetView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }

    let url: URL
    let title: LocalizedStringResource

    @State private var isLoading = true

    var body: some View {
        DBottomSheet(
            title: title,
            fraction: 0.8
        ) {
            ZStack {
                WebDocumentBottomSheetWebView(
                    url: url,
                    isLoading: $isLoading
                )

                if isLoading {
                    color.grayscaleBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .shimmering()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .animation(
            theme.animation,
            value: isLoading
        )
    }
}
