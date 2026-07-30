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
    /// Превью рисуется в PhotoCard размером 64pt, поэтому 192px хватает
    /// вплоть до 3x.
    static let thumbnailMaxDimension: CGFloat = 192
    static let thumbnailCompressionQuality: CGFloat = 0.8

    var id: UUID = .init()
    let image: UIImage
    /// Уменьшенная копия для списков: полноразмерный кадр в 64pt-плитке
    /// заставлял main-поток декодировать всё изображение целиком.
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

    /// Готовит превью вне main-потока — путь захвата и выбора из галереи.
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
