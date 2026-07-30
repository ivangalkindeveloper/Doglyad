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

    /// Декодирует и уменьшает изображение один раз, чтобы списки не
    /// декодировали полный кадр на main при рендере превью.
    /// Результат — bitmap ровно `maxDimension` пикселей по большей стороне
    /// (scale = 1), а не в масштабе экрана.
    func thumbnail(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > 0 else { return self }

        let ratio = min(1, maxDimension / maxSide)
        let targetSize = CGSize(
            width: max(1, (size.width * ratio).rounded()),
            height: max(1, (size.height * ratio).rounded())
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: targetSize,
            format: format
        )
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
