import UIKit

extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let aspectRatio = size.width / size.height
        let targetSize: CGSize

        if size.width > size.height {
            targetSize = CGSize(
                width: min(size.width, maxDimension),
                height: min(size.width, maxDimension) / aspectRatio
            )
        } else {
            targetSize = CGSize(
                width: min(size.height, maxDimension) * aspectRatio,
                height: min(size.height, maxDimension)
            )
        }

        guard targetSize.width < size.width else { return self }

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
