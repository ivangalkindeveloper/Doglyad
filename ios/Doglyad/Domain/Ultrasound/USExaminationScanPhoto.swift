import DoglyadDatabase
import UIKit

struct ScanPhotoEncodingOptions {
    let resizeMaxDimension: Double
    let compressionQuality: Double
}

extension CodingUserInfoKey {
    static let scanPhotoEncodingOptions = CodingUserInfoKey(rawValue: "scanPhotoEncodingOptions")!
}

struct USExaminationScanPhoto: Identifiable, Equatable, Codable {
    /// The preview is drawn in a 64pt PhotoCard, so 192px is enough
    /// all the way up to 3x.
    static let thumbnailMaxDimension: CGFloat = 192
    static let thumbnailCompressionQuality: CGFloat = 0.8

    var id: UUID = .init()
    let image: UIImage
    /// A downscaled copy for lists: a full-size frame in a 64pt tile forced
    /// the main thread to decode the entire image.
    let thumbnail: UIImage

    init(
        id: UUID = UUID(),
        image: UIImage,
        thumbnail: UIImage? = nil
    ) {
        self.id = id
        self.image = image
        self.thumbnail = thumbnail ?? image.thumbnail(maxDimension: Self.thumbnailMaxDimension)
    }

    /// Prepares the preview off the main thread — the capture and gallery-pick path.
    static func make(
        image: UIImage
    ) async -> USExaminationScanPhoto {
        let thumbnail = await Task.detached(priority: .userInitiated) {
            image.thumbnail(maxDimension: Self.thumbnailMaxDimension)
        }.value

        return USExaminationScanPhoto(
            image: image,
            thumbnail: thumbnail
        )
    }

    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        let data = try container.decode(Data.self, forKey: .data)
        let image = UIImage(data: data) ?? UIImage()
        self.image = image
        thumbnail = image.thumbnail(maxDimension: Self.thumbnailMaxDimension)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        guard let options = encoder.userInfo[.scanPhotoEncodingOptions] as? ScanPhotoEncodingOptions else {
            let data = image.pngData() ?? Data()
            try container.encode(data, forKey: .data)
            return
        }

        let resizedImage = image.resized(maxDimension: options.resizeMaxDimension)
        let data = resizedImage.jpegData(compressionQuality: options.compressionQuality) ?? Data()
        try container.encode(data, forKey: .data)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

private extension USExaminationScanPhoto {
    enum CodingKeys: String, CodingKey {
        case data
    }
}

extension USExaminationScanPhoto {
    static func fromDB(
        _ db: USExaminationScanPhotoDB
    ) -> USExaminationScanPhoto {
        USExaminationScanPhoto(
            id: db.id,
            image: UIImage(data: db.data) ?? UIImage(),
            thumbnail: db.thumbnailData.flatMap { UIImage(data: $0) }
        )
    }

    func toDB() -> USExaminationScanPhotoDB {
        USExaminationScanPhotoDB(
            id: id,
            data: image.pngData() ?? Data(),
            thumbnailData: thumbnail.jpegData(
                compressionQuality: Self.thumbnailCompressionQuality
            )
        )
    }
}
