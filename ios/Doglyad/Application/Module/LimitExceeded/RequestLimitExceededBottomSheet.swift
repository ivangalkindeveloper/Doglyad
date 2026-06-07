import Router
import SwiftUI

struct RequestLimitExceededBottomSheet: View {
    @EnvironmentObject private var router: DRouter
    let arguments: RequestLimitExceededArguments?

    var body: some View {
        RequestLimitExceededBottomSheetView(
            viewModel: RequestViewModel(
                router: router
            )
        )
    }
}

#Preview {
    RequestLimitExceededBottomSheet(
        arguments: nil
    )
    .previewable()
}
