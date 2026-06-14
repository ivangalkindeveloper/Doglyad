import PhotosUI
import SwiftUI

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @EnvironmentObject private var router: DRouter
    let arguments: PhotoLibraryPickerArguments

    func makeUIViewController(
        context: Context
    ) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = arguments.selectionLimit

        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onComplete: { images in
                router.dismissSheet()
                arguments.onComplete(images)
            }
        )
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let onComplete: ([UIImage]) -> Void

        init(
            onComplete: @escaping ([UIImage]) -> Void
        ) {
            self.onComplete = onComplete
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            let providers = results
                .map(\.itemProvider)
                .filter { $0.canLoadObject(ofClass: UIImage.self) }

            guard !providers.isEmpty else {
                onComplete([])
                return
            }

            var images = [UIImage?](repeating: nil, count: providers.count)
            let lock = NSLock()
            let group = DispatchGroup()

            for (index, provider) in providers.enumerated() {
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        lock.lock()
                        images[index] = image
                        lock.unlock()
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) { [onComplete] in
                onComplete(images.compactMap { $0 })
            }
        }
    }
}
