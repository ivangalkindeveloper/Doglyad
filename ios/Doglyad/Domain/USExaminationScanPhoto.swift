import DoglyadDatabase
import UIKit

struct USExaminationScanPhoto: Identifiable, Equatable, Codable {
    var id: UUID = .init()
    let image: UIImage

    init(
        id: UUID = UUID(),
        image: UIImage
    ) {
        self.id = id
        self.image = image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        let data = try container.decode(Data.self, forKey: .data)
        image = UIImage(data: data) ?? UIImage()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let resizedImage = image.resized(maxDimension: 128)
        let data = resizedImage.jpegData(compressionQuality: 0.3) ?? Data()
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
            image: UIImage(data: db.data) ?? UIImage()
        )
    }

    func toDB() -> USExaminationScanPhotoDB {
        USExaminationScanPhotoDB(
            id: id,
            data: image.pngData() ?? Data()
        )
    }
}
