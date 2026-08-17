import Foundation
import UIKit

@MainActor
final class ErrorViewModel: DViewModel {
    let email: String?

    init(
        email: String?
    ) {
        self.email = email
        super.init()
    }

    func onTapEmail() {
        guard let email else { return }
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let url = URL(string: "mailto:\(encodedEmail)") else { return }
        UIApplication.shared.open(url)
    }
}
