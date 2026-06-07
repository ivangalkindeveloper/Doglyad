import RevenueCatUI
import SwiftUI

struct SubscriptionCustomerCenterSheetView: View {
    @StateObject var viewModel: SubscriptionCustomerCenterViewModel

    var body: some View {
        CustomerCenterView()
            .onCustomerCenterRestoreCompleted { _ in
                viewModel.onRestoreCompleted()
            }
    }
}
