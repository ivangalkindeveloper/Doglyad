//
//  AnamnesisCameraView.swift
//  Doglyad
//
//  Created by Иван Галкин on 07.10.2025.
//

import SwiftUI
import AVFoundation

struct AnamnesisCameraView: UIViewRepresentable {
    @ObservedObject var viewModel: AnamnesisCameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let layer = AVCaptureVideoPreviewLayer(
            session: viewModel.session
        )
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(layer)
        context.coordinator.previewLayer = layer
        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: Context
    ) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
