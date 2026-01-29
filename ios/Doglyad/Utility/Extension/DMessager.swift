import DoglyadUI

extension DMessager {
    func showUnknownError() -> Void {
        self.show(
            type: .error,
            title: .errorUnknownTitle,
            description: .errorUnknownDescription
        )
    }
}
