import DoglyadDatabase
import UIKit

struct USExaminationScanPhoto: Identifiable, Equatable, Codable {
    var id: UUID = .init()
    let imageData: Data

    var image: UIImage { UIImage(data: imageData)! }

    init(
        id: UUID = UUID(),
        image: UIImage
    ) {
        self.id = id
        imageData = image.jpegData(compressionQuality: 1) ?? Data()
    }
}

private extension USExaminationScanPhoto {
    enum CodingKeys: String, CodingKey {
        case imageData
    }
}

extension USExaminationScanPhoto {
    static func fromDB(
        _ db: USExaminationScanPhotoDB
    ) -> USExaminationScanPhoto {
        USExaminationScanPhoto(
            id: db.id,
            image: UIImage(data: db.imageData) ?? UIImage()
        )
    }

    func toDB() -> USExaminationScanPhotoDB {
        USExaminationScanPhotoDB(
            id: id,
            imageData: imageData
        )
    }
}
