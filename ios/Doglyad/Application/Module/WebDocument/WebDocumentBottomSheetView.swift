import DoglyadUI
import SwiftUI

struct WebDocumentBottomSheetView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }

    let url: URL
    let title: LocalizedStringResource

    @State private var isLoading = true

    var body: some View {
        DBottomSheet(
            title: title,
            fraction: 0.8
        ) { toolbarHeight, bottomHeight in
            ZStack {
                WebDocumentBottomSheetWebView(
                    url: url,
                    topInset: toolbarHeight,
                    bottomInset: bottomHeight,
                    isLoading: $isLoading
                )

                if isLoading {
                    color.grayscaleBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .dShimmer(cornerRadius: 0)
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
