import RevenueCatUI
import SwiftUI

struct SubscriptionPaywallScreenView: View {
    @EnvironmentObject private var router: DRouter
    @StateObject var viewModel: SubscriptionPaywallViewModel

    var body: some View {
        PaywallView(
            fonts: DPaywallFontProvider(),
            displayCloseButton: !router.path.isEmpty
        )
        .onPurchaseCompleted { _ in
            viewModel.onPurchaseCompleted()
        }
        .onRestoreCompleted { customerInfo in
            viewModel.onRestoreCompleted(customerInfo: customerInfo)
        }
        .onRequestedDismissal {
            viewModel.onRequestedDismissal()
        }
    }
}
