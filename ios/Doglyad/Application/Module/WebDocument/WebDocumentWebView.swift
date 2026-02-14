import DoglyadUI
import SwiftUI
import WebKit

struct WebDocumentBottomSheetWebView: UIViewRepresentable {
    @Environment(\.locale) private var locale
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }

    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let backgroundColor = UIColor(color.grayscaleBackgroundWeak)
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = backgroundColor
        webView.scrollView.backgroundColor = backgroundColor
        webView.underPageBackgroundColor = backgroundColor
        webView.navigationDelegate = context.coordinator
        let language = locale.language.languageCode?.identifier ?? "en"
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "lang", value: language)]
        var request = URLRequest(url: components?.url ?? url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        webView.load(request)
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebDocumentBottomSheetWebView

        init(parent: WebDocumentBottomSheetWebView) {
            self.parent = parent
        }

        func webView(
            _: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url,
               url.scheme == "mailto"
            {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
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
