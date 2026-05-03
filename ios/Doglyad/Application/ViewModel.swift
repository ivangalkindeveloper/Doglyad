import DoglyadNetwork
import Foundation
import Handler

@MainActor
class DViewModel: Handler<DHttpApiError, DHttpConnectionError>, ObservableObject {
    private var isInitialized = false

    final func onAppear() {
        guard !isInitialized else { return }
        isInitialized = true
        onInit()
    }

    func onInit() {}
}
