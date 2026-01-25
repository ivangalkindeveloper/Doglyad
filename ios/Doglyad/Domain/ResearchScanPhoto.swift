import UIKit

struct ResearchScanPhoto: Identifiable, Equatable, Codable {
    let id = UUID()
    let imageData: Data
    
    var image: UIImage { UIImage(data: imageData)! }

    init(
        image: UIImage
    ) {
        self.imageData = image.jpegData(compressionQuality: 0.9) ?? Data()
    }
    
    private enum CodingKeys: String, CodingKey {
        case imageData
    }
}
