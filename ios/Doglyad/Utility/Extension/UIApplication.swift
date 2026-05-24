import UIKit

extension UIApplication {
    static func openSettings() {
        guard let settingsURL = URL(string: openSettingsURLString) else { return }
        guard shared.canOpenURL(settingsURL) else { return }
        shared.open(settingsURL)
    }

    static func openAppStore(
        appleUpdateUrl: URL,
        id: String
    ) {
        let url = appleUpdateUrl.appendingPathComponent(id)
        guard shared.canOpenURL(url) else { return }
        shared.open(url)
    }
}
