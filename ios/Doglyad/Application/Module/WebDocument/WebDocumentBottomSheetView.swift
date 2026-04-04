import DoglyadUI
import Shimmer
import SwiftUI

struct WebDocumentBottomSheetView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }

    let url: URL
    let title: LocalizedStringResource

    @State private var isLoading = true

    var body: some View {
        DBottomSheet(
            title: title,
            fraction: 0.8
        ) { toolbarHeight in
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
            .padding(.top, toolbarHeight)
            .edgesIgnoringSafeArea(.bottom)
        }
        .animation(
            theme.animation,
            value: isLoading
        )
    }
}
