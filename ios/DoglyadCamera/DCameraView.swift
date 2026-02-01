import AVFoundation
import SwiftUI

public struct DCameraView: UIViewRepresentable {
    var controller: DCameraController

    public init(
        controller: DCameraController
    ) {
        self.controller = controller
    }

    public func makeUIView(context _: Context) -> UIView {
        let view = UIView(frame: .zero)
        controller.previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(controller.previewLayer)
        return view
    }

    public func updateUIView(
        _: UIView,
        context _: Context
    ) {}
}
