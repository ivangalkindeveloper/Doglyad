import DoglyadDatabase
import UIKit

struct ResearchScanPhoto: Identifiable, Equatable, Codable {
    var id: UUID = .init()
    let imageData: Data

    var image: UIImage { UIImage(data: imageData)! }

    init(
        id: UUID = UUID(),
        image: UIImage
    ) {
        self.id = id
        imageData = image.jpegData(compressionQuality: 0.9) ?? Data()
    }
}

private extension ResearchScanPhoto {
    enum CodingKeys: String, CodingKey {
        case imageData
    }
}

extension ResearchScanPhoto {
    static func fromDB(
        _ db: ResearchScanPhotoDB
    ) -> ResearchScanPhoto {
        ResearchScanPhoto(
            id: db.id,
            image: UIImage(data: db.imageData) ?? UIImage()
        )
    }

    func toDB() -> ResearchScanPhotoDB {
        ResearchScanPhotoDB(
            id: id,
            imageData: imageData
        )
    }
}
