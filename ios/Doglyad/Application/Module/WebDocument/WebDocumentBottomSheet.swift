import DoglyadUI
import Router
import SwiftUI

struct WebDocumentBottomSheet: View {
    let arguments: WebDocumentBottomSheetArguments

    var body: some View {
        WebDocumentBottomSheetView(
            url: arguments.url,
            title: arguments.title
        )
    }
}

#Preview {
    WebDocumentBottomSheet(
        arguments: WebDocumentBottomSheetArguments(
            url: URL(string: "https://ivangalkindeveloper.github.io/Doglyad/legal/privacy-policy/")!,
            title: .privacyPolicyTitle
        )
    )
    .previewable()
}
