import DoglyadUI
import Router
import Shimmer
import SwiftUI
import WebKit

final class WebDocumentBottomSheetArguments: RouteArgumentsProtocol {
    let url: URL
    let title: LocalizedStringResource

    init(
        url: URL,
        title: LocalizedStringResource
    ) {
        self.url = url
        self.title = title
    }
}

struct WebDocumentBottomSheet: View {
    let arguments: WebDocumentBottomSheetArguments

    var body: some View {
        WebDocumentBottomSheetView(
            url: arguments.url,
            title: arguments.title
        )
    }
}

private struct WebDocumentBottomSheetView: View {
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
                WebDocumentWebView(
                    url: url,
                    isLoading: $isLoading
                )

                if isLoading {
                    VStack(spacing: size.s16) {
                        ForEach(0 ..< 8, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: size.s8)
                                .fill(color.grayscalePlacehold.opacity(0.3))
                                .frame(height: size.s16)
                                .shimmering()
                        }
                    }
                    .padding(size.s16)
                }
            }
        }
        .animation(
            theme.animation,
            value: isLoading
        )
    }
}

private struct WebDocumentWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebDocumentWebView

        init(parent: WebDocumentWebView) {
            self.parent = parent
        }

        func webView(
            _: WKWebView,
            didFinish _: WKNavigation!
        ) {
            parent.isLoading = false
        }

        func webView(
            _: WKWebView,
            didFail _: WKNavigation!,
            withError _: Error
        ) {
            parent.isLoading = false
        }
    }
}
