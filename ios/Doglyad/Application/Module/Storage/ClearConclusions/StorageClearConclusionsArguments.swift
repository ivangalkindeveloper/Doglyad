import Router

final class StorageClearConclusionsArguments: RouteArgumentsProtocol {
    let onConfirm: () -> Void

    init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
    }
}
